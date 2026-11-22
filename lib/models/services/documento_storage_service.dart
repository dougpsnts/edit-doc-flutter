import 'package:shared_preferences/shared_preferences.dart';

import '../documento.dart';
import 'storage_utils.dart';

/// CRUD de documentos. Cada usuário tem a sua lista, serializada em JSON
/// (jsonEncode/jsonDecode + toMap/fromMap) sob a chave `documentos_<email>`.
class DocumentoStorageService {
  String _chave(String email) => 'documentos_${email.trim().toLowerCase()}';

  List<Documento> _converter(SharedPreferences prefs, String email) {
    final documentos = <Documento>[];
    for (final mapa in lerListaJson(prefs, _chave(email))) {
      try {
        documentos.add(Documento.fromMap(mapa));
      } catch (_) {
        // Item corrompido: ignorado.
      }
    }
    return documentos;
  }

  Future<void> _gravar(
    SharedPreferences prefs,
    String email,
    List<Documento> documentos,
  ) {
    return gravarListaJson(prefs, _chave(email), [
      for (final d in documentos) d.toMap(),
    ]);
  }

  Future<List<Documento>> listar(String email) async {
    final prefs = await abrirPreferencias();
    return _converter(prefs, email);
  }

  Future<void> criar(String email, Documento documento) async {
    final prefs = await abrirPreferencias();
    final documentos = _converter(prefs, email)..add(documento);
    await _gravar(prefs, email, documentos);
  }

  Future<void> atualizar(String email, Documento documento) async {
    final prefs = await abrirPreferencias();
    final documentos = _converter(prefs, email);
    final indice = documentos.indexWhere((d) => d.id == documento.id);
    if (indice < 0) throw StorageException('Documento não encontrado.');
    documentos[indice] = documento;
    await _gravar(prefs, email, documentos);
  }

  Future<void> excluir(String email, String id) async {
    final prefs = await abrirPreferencias();
    final documentos = _converter(prefs, email);
    final tamanhoAntes = documentos.length;
    documentos.removeWhere((d) => d.id == id);
    if (documentos.length == tamanhoAntes) {
      throw StorageException('Documento não encontrado.');
    }
    await _gravar(prefs, email, documentos);
  }
}
