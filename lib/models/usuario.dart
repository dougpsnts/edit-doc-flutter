/// Usuário cadastrado localmente.
class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  final int id;
  final String nome;
  final String email;

  /// ATENÇÃO: armazenada em texto simples no armazenamento local do dispositivo.
  /// Isto NÃO é autenticação segura; ver ARQUITETURA.md.
  final String senha;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'email': email,
        'senha': senha,
      };

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: (map['id'] as num).toInt(),
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
    );
  }
}
