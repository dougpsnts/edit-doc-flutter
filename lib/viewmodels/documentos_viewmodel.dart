import 'package:flutter/foundation.dart';

import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';
import '../models/services/storage_utils.dart';

/// Estado e regras de negócio do CRUD de documentos do usuário logado.
/// As Views nunca acessam o armazenamento diretamente: tudo passa por aqui.
class DocumentosViewModel extends ChangeNotifier {
  DocumentosViewModel(this._storage);

  final DocumentoStorageService _storage;

  String? _emailAtual;
  List<Documento> _documentos = const [];
  bool _carregando = false;
  String? _erro;

  List<Documento> get documentos => _documentos;
  bool get carregando => _carregando;
  String? get erro => _erro;

  List<Documento> _ordenar(Iterable<Documento> origem) {
    final lista = origem.toList()
      ..sort((a, b) => b.atualizadoEm.compareTo(a.atualizadoEm));
    return List.unmodifiable(lista);
  }

  /// READ: carrega os documentos do usuário informado.
  Future<void> carregarPara(String email) async {
    _emailAtual = email;
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _documentos = _ordenar(await _storage.listar(email));
    } on StorageException catch (e) {
      _documentos = const [];
      _erro = e.mensagem;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> recarregar() async {
    final email = _emailAtual;
    if (email != null) await carregarPara(email);
  }

  /// Limpa o estado (usado no logout).
  void limpar() {
    _emailAtual = null;
    _documentos = const [];
    _carregando = false;
    _erro = null;
    notifyListeners();
  }

  Documento? buscar(String id) {
    for (final d in _documentos) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// CREATE
  Future<bool> criar({required String titulo, required String conteudo}) async {
    final email = _emailAtual;
    if (email == null) return _falhar('Nenhum usuário autenticado.');
    final agora = DateTime.now();
    final documento = Documento(
      id: agora.microsecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      conteudo: conteudo,
      criadoEm: agora,
      atualizadoEm: agora,
    );
    try {
      await _storage.criar(email, documento);
      _documentos = _ordenar([..._documentos, documento]);
      _erro = null;
      notifyListeners();
      return true;
    } on StorageException catch (e) {
      return _falhar(e.mensagem);
    }
  }

  /// UPDATE
  Future<bool> atualizar({
    required String id,
    required String titulo,
    required String conteudo,
  }) async {
    final email = _emailAtual;
    final original = buscar(id);
    if (email == null) return _falhar('Nenhum usuário autenticado.');
    if (original == null) return _falhar('Documento não encontrado.');
    final atualizado = original.copyWith(
      titulo: titulo.trim(),
      conteudo: conteudo,
      atualizadoEm: DateTime.now(),
    );
    try {
      await _storage.atualizar(email, atualizado);
      _documentos = _ordenar([
        for (final d in _documentos) d.id == id ? atualizado : d,
      ]);
      _erro = null;
      notifyListeners();
      return true;
    } on StorageException catch (e) {
      return _falhar(e.mensagem);
    }
  }

  /// DELETE (a confirmação é pedida pela View antes de chamar este método)
  Future<bool> excluir(String id) async {
    final email = _emailAtual;
    if (email == null) return _falhar('Nenhum usuário autenticado.');
    try {
      await _storage.excluir(email, id);
      _documentos = _ordenar(_documentos.where((d) => d.id != id));
      _erro = null;
      notifyListeners();
      return true;
    } on StorageException catch (e) {
      return _falhar(e.mensagem);
    }
  }

  bool _falhar(String mensagem) {
    _erro = mensagem;
    notifyListeners();
    return false;
  }
}
