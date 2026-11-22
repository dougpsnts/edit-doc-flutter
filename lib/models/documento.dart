/// Documento de texto criado pelo usuário.
class Documento {
  const Documento({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final String id;
  final String titulo;
  final String conteudo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Documento copyWith({
    String? titulo,
    String? conteudo,
    DateTime? atualizadoEm,
  }) {
    return Documento(
      id: id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'criadoEm': criadoEm.toIso8601String(),
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };

  /// Lança exceção se algum campo estiver ausente ou com tipo inválido;
  /// quem lê a lista salva trata o erro e descarta o item corrompido.
  factory Documento.fromMap(Map<String, dynamic> map) {
    return Documento(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      conteudo: map['conteudo'] as String,
      criadoEm: DateTime.parse(map['criadoEm'] as String),
      atualizadoEm: DateTime.parse(map['atualizadoEm'] as String),
    );
  }
}
