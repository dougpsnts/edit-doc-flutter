import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../models/services/preferences_service.dart';
import '../utils/formatadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';
import '../viewmodels/tema_viewmodel.dart';

const String nomeDesenvolvedor = 'Douglas Pereira';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.authVm,
    required this.documentosVm,
    required this.temaVm,
  });

  final AuthViewModel authVm;
  final DocumentosViewModel documentosVm;
  final TemaViewModel temaVm;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    final email = widget.authVm.usuario?.email;
    if (email != null) {
      // Adiado para depois do primeiro frame: evita notificar durante o build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.documentosVm.carregarPara(email);
      });
    }
  }

  Future<void> _sair() async {
    await widget.authVm.sair();
    widget.documentosVm.limpar();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  Future<void> _excluir(Documento documento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir documento'),
        content: Text(
          'Deseja realmente excluir "${documento.titulo}"? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final ok = await widget.documentosVm.excluir(documento.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Documento excluído.'
              : widget.documentosVm.erro ?? 'Não foi possível excluir.',
        ),
      ),
    );
  }

  void _mostrarPreferencias() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: ListenableBuilder(
          listenable: widget.temaVm,
          builder: (context, _) {
            final tema = widget.temaVm;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferências do usuário',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode),
                    title: const Text('Tema escuro'),
                    value: tema.themeMode == ThemeMode.dark,
                    onChanged: (_) => tema.alternarTema(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.format_size),
                    title: Text('Tamanho da fonte: ${tema.tamanhoFonte.round()}'),
                  ),
                  Slider(
                    value: tema.tamanhoFonte,
                    min: PreferencesService.fonteMinima,
                    max: PreferencesService.fonteMaxima,
                    divisions: 12,
                    label: tema.tamanhoFonte.round().toString(),
                    onChanged: tema.definirTamanhoFonte,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _mostrarUsuarios() async {
    final usuarios = await widget.authVm.listarUsuarios();
    if (!mounted) return;
    showModalBottomSheet<void>(
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
                    leading: CircleAvatar(child: Text('${u.id}')),
                    title: Text(u.nome),
                    subtitle: Text(u.email),
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
    final nome = widget.authVm.usuario?.nome ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, $nome!'),
        actions: [
          ListenableBuilder(
            listenable: widget.temaVm,
            builder: (context, _) => IconButton(
              tooltip: 'Alternar tema',
              icon: Icon(
                widget.temaVm.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: widget.temaVm.alternarTema,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (valor) {
              if (valor == 'prefs') _mostrarPreferencias();
              if (valor == 'usuarios') _mostrarUsuarios();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'prefs', child: Text('Preferências')),
              PopupMenuItem(
                value: 'usuarios',
                child: Text('Usuários cadastrados'),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/editor'),
        icon: const Icon(Icons.add),
        label: const Text('Novo documento'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListenableBuilder(
            listenable: widget.documentosVm,
            builder: (context, _) => _corpo(context),
          ),
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: Center(
          child: Text(
            'Desenvolvido por: $nomeDesenvolvedor',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _corpo(BuildContext context) {
    final vm = widget.documentosVm;

    if (vm.carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.erro != null && vm.documentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.erro!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: vm.recarregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (vm.documentos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum documento ainda.\nToque em "Novo documento" para começar.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: vm.documentos.length,
      itemBuilder: (context, i) {
        final doc = vm.documentos[i];
        return Card(
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            leading: const Icon(Icons.description, size: 32),
            title: Text(doc.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${doc.conteudo}\nAtualizado em ${formatarDataHora(doc.atualizadoEm)}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            onTap: () => Navigator.pushNamed(context, '/editor', arguments: doc.id),
            trailing: IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _excluir(doc),
            ),
          ),
        );
      },
    );
  }
}
