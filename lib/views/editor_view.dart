import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../utils/validadores.dart';
import '../viewmodels/documentos_viewmodel.dart';

/// Cria (documentoId == null) ou edita (documentoId informado) um documento.
class EditorView extends StatefulWidget {
  const EditorView({super.key, required this.documentosVm, this.documentoId});

  final DocumentosViewModel documentosVm;
  final String? documentoId;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _formKey = GlobalKey<FormState>();
  late final Documento? _original;
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _conteudoCtrl;
  bool _salvando = false;

  bool get _editando => widget.documentoId != null;
  bool get _naoEncontrado => _editando && _original == null;

  bool get _alterado =>
      _tituloCtrl.text != (_original?.titulo ?? '') ||
      _conteudoCtrl.text != (_original?.conteudo ?? '');

  @override
  void initState() {
    super.initState();
    final id = widget.documentoId;
    _original = id == null ? null : widget.documentosVm.buscar(id);
    _tituloCtrl = TextEditingController(text: _original?.titulo ?? '');
    _conteudoCtrl = TextEditingController(text: _original?.conteudo ?? '');
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _conteudoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final vm = widget.documentosVm;
    final ok = _editando
        ? await vm.atualizar(
            id: widget.documentoId!,
            titulo: _tituloCtrl.text,
            conteudo: _conteudoCtrl.text,
          )
        : await vm.criar(titulo: _tituloCtrl.text, conteudo: _conteudoCtrl.text);

    if (!mounted) return;
    setState(() => _salvando = false);

    final messenger = ScaffoldMessenger.of(context);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(vm.erro ?? 'Não foi possível salvar.')),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _editando ? 'Documento atualizado.' : 'Documento criado.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _cancelar() async {
    if (!_alterado) {
      Navigator.pop(context);
      return;
    }
    final descartar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('As alterações não salvas serão perdidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (descartar == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_naoEncontrado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar documento')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Documento não encontrado.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar documento' : 'Novo documento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancelar',
          onPressed: _salvando ? null : _cancelar,
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => validarObrigatorio(v, 'o título'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _conteudoCtrl,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: 'Conteúdo',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => validarObrigatorio(v, 'o conteúdo'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _salvando ? null : _cancelar,
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _salvando ? null : _salvar,
                          icon: _salvando
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Salvar'),
                        ),
                      ),
                    ],
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
