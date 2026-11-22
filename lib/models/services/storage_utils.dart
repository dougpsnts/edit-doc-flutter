import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Falha de leitura/gravação no armazenamento local.
class StorageException implements Exception {
  StorageException(this.mensagem);

  final String mensagem;

  @override
  String toString() => 'StorageException: $mensagem';
}

Future<SharedPreferences> abrirPreferencias() async {
  try {
    return await SharedPreferences.getInstance();
  } catch (_) {
    throw StorageException('Não foi possível acessar o armazenamento local.');
  }
}

/// Lê uma lista de mapas gravada como JSON. Dado inexistente ou JSON inválido
/// resultam em lista vazia (nunca lançam exceção).
List<Map<String, dynamic>> lerListaJson(SharedPreferences prefs, String chave) {
  try {
    final bruto = prefs.getString(chave);
    if (bruto == null || bruto.isEmpty) return [];
    final decodificado = jsonDecode(bruto);
    if (decodificado is! List) return [];
    return [
      for (final item in decodificado)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  } catch (_) {
    return [];
  }
}

Future<void> gravarListaJson(
  SharedPreferences prefs,
  String chave,
  List<Map<String, dynamic>> itens,
) async {
  bool ok;
  try {
    ok = await prefs.setString(chave, jsonEncode(itens));
  } catch (_) {
    ok = false;
  }
  if (!ok) throw StorageException('Não foi possível gravar os dados.');
}
