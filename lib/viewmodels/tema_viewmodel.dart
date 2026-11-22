import 'package:flutter/material.dart';

import '../models/services/preferences_service.dart';
import '../models/services/storage_utils.dart';

/// Estado centralizado de tema (claro/escuro) e tamanho da fonte.
class TemaViewModel extends ChangeNotifier {
  TemaViewModel(this._preferencias);

  final PreferencesService _preferencias;

  ThemeMode _themeMode = ThemeMode.light;
  double _tamanhoFonte = PreferencesService.fontePadrao;
  String? _erro;

  ThemeMode get themeMode => _themeMode;
  double get tamanhoFonte => _tamanhoFonte;
  String? get erro => _erro;

  /// Recupera as preferências salvas (chamado na inicialização do app).
  Future<void> carregar() async {
    try {
      _themeMode = await _preferencias.lerTema();
      _tamanhoFonte = await _preferencias.lerTamanhoFonte();
    } on StorageException catch (e) {
      _erro = e.mensagem;
    }
    notifyListeners();
  }

  Future<void> definirTema(ThemeMode modo) async {
    _themeMode = modo;
    _erro = null;
    notifyListeners();
    try {
      await _preferencias.salvarTema(modo);
    } on StorageException catch (e) {
      _erro = e.mensagem;
      notifyListeners();
    }
  }

  Future<void> alternarTema() {
    return definirTema(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> definirTamanhoFonte(double tamanho) async {
    _tamanhoFonte = tamanho.clamp(
      PreferencesService.fonteMinima,
      PreferencesService.fonteMaxima,
    ).toDouble();
    _erro = null;
    notifyListeners();
    try {
      await _preferencias.salvarTamanhoFonte(_tamanhoFonte);
    } on StorageException catch (e) {
      _erro = e.mensagem;
      notifyListeners();
    }
  }
}
