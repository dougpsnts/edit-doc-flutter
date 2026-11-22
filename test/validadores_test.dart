import 'package:edit_doc_flutter/utils/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validarNome', () {
    expect(validarNome(''), isNotNull);
    expect(validarNome('Al'), isNotNull);
    expect(validarNome('Douglas Pereira'), isNull);
  });

  test('validarEmail', () {
    expect(validarEmail(''), isNotNull);
    expect(validarEmail('sem-arroba'), isNotNull);
    expect(validarEmail('a@b.com'), isNull);
  });

  test('validarSenhaCadastro exige 6 caracteres', () {
    expect(validarSenhaCadastro('12345'), isNotNull);
    expect(validarSenhaCadastro('123456'), isNull);
  });

  test('validarObrigatorio', () {
    expect(validarObrigatorio('  ', 'o título'), isNotNull);
    expect(validarObrigatorio('x', 'o título'), isNull);
  });
}
