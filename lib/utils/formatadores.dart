/// Formata uma data/hora como dd/MM/aaaa HH:mm (sem depender do pacote intl).
String formatarDataHora(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  final d = data.toLocal();
  return '${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}';
}
