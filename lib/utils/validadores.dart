/// Funções de validação reutilizadas pelos formulários (retornam `null` quando válido).
String? validarNome(String? value) {
  final nome = value?.trim() ?? '';
  if (nome.isEmpty) return 'Informe o nome completo';
  if (nome.length < 3) return 'O nome deve ter ao menos 3 caracteres';
  return null;
}

String? validarEmail(String? value) {
  final email = value?.trim() ?? '';
  final regex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
  if (email.isEmpty) return 'Informe o e-mail';
  if (!regex.hasMatch(email)) return 'E-mail inválido';
  return null;
}

/// Regra de senha para o cadastro.
String? validarSenhaCadastro(String? value) {
  if (value == null || value.isEmpty) return 'Informe a senha';
  if (value.length < 6) return 'A senha deve ter ao menos 6 caracteres';
  return null;
}

/// No login basta que a senha tenha sido informada.
String? validarSenhaLogin(String? value) {
  if (value == null || value.isEmpty) return 'Informe a senha';
  return null;
}

String? validarObrigatorio(String? value, String campo) {
  if (value == null || value.trim().isEmpty) return 'Informe $campo';
  return null;
}
