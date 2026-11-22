import 'package:flutter/material.dart';

import '../models/services/preferences_service.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/tema_viewmodel.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key, required this.authVm, required this.temaVm});

  final AuthViewModel authVm;
  final TemaViewModel temaVm;

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  late ThemeMode _tema = widget.temaVm.themeMode;
  late double _tamanhoFonte = widget.temaVm.tamanhoFonte;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await widget.authVm.cadastrar(
      nome: _nomeCtrl.text,
      email: _emailCtrl.text,
      senha: _senhaCtrl.text,
    );
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.authVm.erro ?? 'Não foi possível cadastrar.'),
        ),
      );
      return;
    }

    await widget.temaVm.definirTema(_tema);
    await widget.temaVm.definirTamanhoFonte(_tamanhoFonte);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: validarNome,
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
                    validator: validarSenhaCadastro,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Preferências',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ThemeMode>(
                    initialValue: _tema,
                    decoration: const InputDecoration(
                      labelText: 'Tema do app',
                      prefixIcon: Icon(Icons.palette),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Tema claro'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Tema escuro'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _tema = v ?? ThemeMode.light),
                  ),
                  const SizedBox(height: 16),
                  Text('Tamanho da fonte: ${_tamanhoFonte.round()}'),
                  Slider(
                    value: _tamanhoFonte,
                    min: PreferencesService.fonteMinima,
                    max: PreferencesService.fonteMaxima,
                    divisions: 12,
                    label: _tamanhoFonte.round().toString(),
                    onChanged: (v) => setState(() => _tamanhoFonte = v),
                  ),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: widget.authVm,
                    builder: (context, _) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            widget.authVm.carregando ? null : _cadastrar,
                        child: widget.authVm.carregando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Cadastrar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
