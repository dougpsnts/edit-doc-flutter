import 'package:flutter/material.dart';

import 'storage_utils.dart';

/// Preferências do usuário (tema, tamanho da fonte) e dados da sessão.
class PreferencesService {
  static const String _chaveTema = 'tema';
  static const String _chaveFonte = 'tamanho_fonte';
  static const String _chaveSessao = 'sessao_email';

  static const double fonteMinima = 12;
  static const double fonteMaxima = 24;
  static const double fontePadrao = 16;

  Future<ThemeMode> lerTema() async {
    final prefs = await abrirPreferencias();
    return prefs.getString(_chaveTema) == 'Escuro'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> salvarTema(ThemeMode modo) async {
    final prefs = await abrirPreferencias();
    final ok = await prefs.setString(
      _chaveTema,
      modo == ThemeMode.dark ? 'Escuro' : 'Claro',
    );
    if (!ok) throw StorageException('Não foi possível salvar o tema.');
  }

  Future<double> lerTamanhoFonte() async {
    final prefs = await abrirPreferencias();
    final valor = prefs.getDouble(_chaveFonte) ?? fontePadrao;
    return valor.clamp(fonteMinima, fonteMaxima).toDouble();
  }

  Future<void> salvarTamanhoFonte(double tamanho) async {
    final prefs = await abrirPreferencias();
    final ok = await prefs.setDouble(_chaveFonte, tamanho);
    if (!ok) throw StorageException('Não foi possível salvar a fonte.');
  }

  /// E-mail do usuário logado (sessão local), ou `null`.
  Future<String?> lerSessao() async {
    final prefs = await abrirPreferencias();
    return prefs.getString(_chaveSessao);
  }

  Future<void> salvarSessao(String email) async {
    final prefs = await abrirPreferencias();
    final ok = await prefs.setString(_chaveSessao, email.trim().toLowerCase());
    if (!ok) throw StorageException('Não foi possível salvar a sessão.');
  }

  Future<void> limparSessao() async {
    final prefs = await abrirPreferencias();
    await prefs.remove(_chaveSessao);
  }
}
