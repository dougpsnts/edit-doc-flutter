import 'package:shared_preferences/shared_preferences.dart';

import '../usuario.dart';
import 'storage_utils.dart';

/// "Banco" local de usuários: lista serializada em JSON no shared_preferences.
/// Substitui a antiga lista em memória (BancoDadosLocal), que perdia os dados
/// ao atualizar a página.
class BancoLocalService {
  static const String _chave = 'usuarios';

  List<Usuario> _converter(SharedPreferences prefs) {
    final usuarios = <Usuario>[];
    for (final mapa in lerListaJson(prefs, _chave)) {
      try {
        usuarios.add(Usuario.fromMap(mapa));
      } catch (_) {
        // Item corrompido: ignorado.
      }
    }
    return usuarios;
  }

  Future<List<Usuario>> listar() async {
    final prefs = await abrirPreferencias();
    return List.unmodifiable(_converter(prefs));
  }

  /// Retorna `false` se o e-mail já estiver cadastrado.
  Future<bool> inserir(String nome, String email, String senha) async {
    final prefs = await abrirPreferencias();
    final usuarios = _converter(prefs);
    final emailNormalizado = email.trim().toLowerCase();

    if (usuarios.any((u) => u.email == emailNormalizado)) return false;

    final proximoId =
        usuarios.fold<int>(0, (maior, u) => u.id > maior ? u.id : maior) + 1;
    usuarios.add(
      Usuario(
        id: proximoId,
        nome: nome.trim(),
        email: emailNormalizado,
        senha: senha,
      ),
    );
    await gravarListaJson(prefs, _chave, [for (final u in usuarios) u.toMap()]);
    return true;
  }

  Future<Usuario?> buscarPorEmail(String email) async {
    final usuarios = await listar();
    final emailNormalizado = email.trim().toLowerCase();
    for (final u in usuarios) {
      if (u.email == emailNormalizado) return u;
    }
    return null;
  }

  Future<Usuario?> autenticar(String email, String senha) async {
    final usuario = await buscarPorEmail(email);
    if (usuario != null && usuario.senha == senha) return usuario;
    return null;
  }
}
