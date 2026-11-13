import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MeuApp());
}

final ValueNotifier<ThemeMode> temaNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<double> fonteNotifier = ValueNotifier(16.0);

const String nomeDesenvolvedor = 'Seu Nome';

String? validarEmail(String? value) {
  final email = value?.trim() ?? '';
  final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

  if (email.isEmpty) {
    return 'Informe o e-mail';
  }

  if (!regex.hasMatch(email)) {
    return 'E-mail inválido';
  }

  return null;
}

class PreferenciasService {
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }
}

class BancoDadosLocal {
  static final List<Map<String, dynamic>> _tabelaUsuarios = [];
  static int _proximoId = 1;

  static Future<bool> insert(String nome, String email, String senha) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final emailNormalizado = email.trim().toLowerCase();
    final jaExiste = _tabelaUsuarios.any((u) => u['email'] == emailNormalizado);
    if (jaExiste) {
      return false;
    }

    _tabelaUsuarios.add({
      'id': _proximoId++,
      'nome': nome.trim(),
      'email': emailNormalizado,
      'senha': senha,
    });
    return true;
  }

  static Future<List<Map<String, dynamic>>> query() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_tabelaUsuarios);
  }

  static Future<Map<String, dynamic>?> autenticar(
    String email,
    String senha,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    for (final u in _tabelaUsuarios) {
      if (u['email'] == email.trim().toLowerCase() && u['senha'] == senha) {
        return u;
      }
    }

    return null;
  }
}

// ------------------------------------------------------------
// APP + ROTAS
// ------------------------------------------------------------
class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (context, modo, _) {
        return ValueListenableBuilder<double>(
          valueListenable: fonteNotifier,
          builder: (context, fonte, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Atividade Flutter',
              themeMode: modo,
              theme: ThemeData(
                colorSchemeSeed: Colors.indigo,
                brightness: Brightness.light,
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorSchemeSeed: Colors.indigo,
                brightness: Brightness.dark,
                useMaterial3: true,
              ),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(fonte / 16)),
                child: child ?? const SizedBox.shrink(),
              ),
              initialRoute: '/',
              routes: {
                '/': (context) => const TelaLogin(),
                '/cadastro': (context) => const TelaCadastro(),
                '/home': (context) => const TelaHome(),
              },
            );
          },
        );
      },
    );
  }
}

// ------------------------------------------------------------
// TELA DE LOGIN ( / )
// ------------------------------------------------------------
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final usuario = await BancoDadosLocal.autenticar(
      _emailCtrl.text,
      _senhaCtrl.text,
    );

    if (!mounted) return;
    setState(() => _carregando = false);

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha incorretos.')),
      );
      return;
    }

    final tema = await PreferenciasService.getString('tema');
    final fonte = await PreferenciasService.getDouble('tamanho_fonte');

    if (tema != null) {
      temaNotifier.value = tema == 'Escuro' ? ThemeMode.dark : ThemeMode.light;
    }
    if (fonte != null) {
      fonteNotifier.value = fonte;
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: usuario['nome'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.lock_outline, size: 72),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: validarEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe a senha' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// TELA DE CADASTRO ( /cadastro )
// ------------------------------------------------------------
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  String _tema = 'Claro';
  double _tamanhoFonte = 16;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final inseriu = await BancoDadosLocal.insert(
      _nomeCtrl.text,
      _emailCtrl.text,
      _senhaCtrl.text,
    );

    if (!mounted) return;
    if (!inseriu) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este e-mail já está cadastrado!')),
      );
      return;
    }

    await PreferenciasService.setString('tema', _tema);
    await PreferenciasService.setDouble('tamanho_fonte', _tamanhoFonte);

    if (!mounted) return;
    setState(() => _carregando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Informe o nome completo'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: validarEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.key),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'A senha deve ter ao menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Preferências',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tema,
                decoration: const InputDecoration(
                  labelText: 'Tema do App',
                  prefixIcon: Icon(Icons.palette),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Claro', child: Text('Tema Claro')),
                  DropdownMenuItem(value: 'Escuro', child: Text('Tema Escuro')),
                ],
                onChanged: (v) => setState(() => _tema = v ?? 'Claro'),
              ),
              const SizedBox(height: 16),
              Text('Tamanho da fonte: ${_tamanhoFonte.round()}'),
              Slider(
                value: _tamanhoFonte,
                min: 12,
                max: 24,
                divisions: 12,
                label: _tamanhoFonte.round().toString(),
                onChanged: (v) => setState(() => _tamanhoFonte = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// TELA HOME ( /home ) - recebe o nome via arguments
// ------------------------------------------------------------
class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  Future<void> _mostrarPreferencias(BuildContext context) async {
    final tema = await PreferenciasService.getString('tema');
    final fonte = await PreferenciasService.getDouble('tamanho_fonte');

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Preferências do Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Tema'),
              subtitle: Text(tema ?? 'Não definido'),
            ),
            ListTile(
              leading: const Icon(Icons.format_size),
              title: const Text('Tamanho da fonte'),
              subtitle: Text(fonte?.round().toString() ?? 'Não definido'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarUsuarios(BuildContext context) async {
    final usuarios = await BancoDadosLocal.query();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Usuários cadastrados (${usuarios.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: usuarios.length,
                itemBuilder: (_, i) {
                  final u = usuarios[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${u['id']}')),
                    title: Text(u['nome']),
                    subtitle: Text(u['email']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, $nome!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: InkWell(
                onTap: () => _mostrarPreferencias(context),
                child: const ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Icon(Icons.settings, size: 36),
                  title: Text('Preferências do Usuário'),
                  subtitle: Text('Toque para ver tema e fonte salvos'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              child: InkWell(
                onTap: () => _mostrarUsuarios(context),
                child: const ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Icon(Icons.storage, size: 36),
                  title: Text('Usuários no Banco Local'),
                  subtitle: Text('Toque para listar os cadastrados'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Center(
          child: Text(
            'Desenvolvido por: $nomeDesenvolvedor',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
