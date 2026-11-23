import 'package:flutter/foundation.dart';

import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';
import '../models/services/storage_utils.dart';
import '../models/usuario.dart';

/// Autenticação LOCAL (sem servidor): cadastro, login, sessão persistida.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required BancoLocalService bancoLocal,
    required PreferencesService preferencias,
  })  : _banco = bancoLocal,
        _prefs = preferencias;

  final BancoLocalService _banco;
  final PreferencesService _prefs;

  Usuario? _usuario;
  bool _carregando = false;
  String? _erro;

  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;
  bool get carregando => _carregando;
  String? get erro => _erro;

  /// Restaura a sessão salva (usado na inicialização e após F5 na Web).
  Future<void> restaurarSessao() async {
    try {
      final email = await _prefs.lerSessao();
      if (email != null) {
        _usuario = await _banco.buscarPorEmail(email);
        if (_usuario == null) await _prefs.limparSessao();
      }
    } on StorageException catch (e) {
      _erro = e.mensagem;
      _usuario = null;
    }
    notifyListeners();
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final inseriu = await _banco.inserir(nome, email, senha);
      if (!inseriu) _erro = 'Este e-mail já está cadastrado!';
      return inseriu;
    } on StorageException catch (e) {
      _erro = e.mensagem;
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> entrar(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final usuario = await _banco.autenticar(email, senha);
      if (usuario == null) {
        _erro = 'E-mail ou senha incorretos.';
        return false;
      }
      await _prefs.salvarSessao(usuario.email);
      _usuario = usuario;
      return true;
    } on StorageException catch (e) {
      _erro = e.mensagem;
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> sair() async {
    _usuario = null;
    _erro = null;
    try {
      await _prefs.limparSessao();
    } on StorageException catch (e) {
      _erro = e.mensagem;
    }
    notifyListeners();
  }

  Future<List<Usuario>> listarUsuarios() async {
    try {
      return await _banco.listar();
    } on StorageException catch (e) {
      _erro = e.mensagem;
      notifyListeners();
      return const [];
    }
  }
}
