import 'package:edit_doc_flutter/models/documento.dart';
import 'package:edit_doc_flutter/models/services/banco_local_service.dart';
import 'package:edit_doc_flutter/models/services/documento_storage_service.dart';
import 'package:edit_doc_flutter/models/services/storage_utils.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Documento: toMap/fromMap preservam os dados', () {
    final agora = DateTime.utc(2026, 11, 22, 10, 30);
    final original = Documento(
      id: '1',
      titulo: 'T',
      conteudo: 'C',
      criadoEm: agora,
      atualizadoEm: agora,
    );
    final copia = Documento.fromMap(original.toMap());
    expect(copia.id, '1');
    expect(copia.titulo, 'T');
    expect(copia.conteudo, 'C');
    expect(copia.atualizadoEm, agora);
  });

  test('DocumentoStorageService: CRUD persiste entre instâncias', () async {
    final agora = DateTime.now();
    final doc = Documento(
      id: 'a',
      titulo: 'Titulo',
      conteudo: 'Texto',
      criadoEm: agora,
      atualizadoEm: agora,
    );
    await DocumentoStorageService().criar('x@y.com', doc);

    // Nova instância simula reabrir o app (dados vêm do shared_preferences).
    var lista = await DocumentoStorageService().listar('x@y.com');
    expect(lista.length, 1);

    await DocumentoStorageService()
        .atualizar('x@y.com', doc.copyWith(titulo: 'Novo'));
    lista = await DocumentoStorageService().listar('x@y.com');
    expect(lista.single.titulo, 'Novo');

    await DocumentoStorageService().excluir('x@y.com', 'a');
    lista = await DocumentoStorageService().listar('x@y.com');
    expect(lista, isEmpty);
  });

  test('JSON inválido resulta em lista vazia', () async {
    SharedPreferences.setMockInitialValues({'documentos_x@y.com': '{nao é json'});
    expect(await DocumentoStorageService().listar('x@y.com'), isEmpty);
  });

  test('excluir/atualizar inexistente lança StorageException', () async {
    expect(
      () => DocumentoStorageService().excluir('x@y.com', 'nada'),
      throwsA(isA<StorageException>()),
    );
  });

  test('BancoLocalService: cadastro, duplicidade e autenticação', () async {
    final banco = BancoLocalService();
    expect(await banco.inserir('Ana Silva', 'ANA@x.com', '123456'), isTrue);
    expect(await banco.inserir('Outra', 'ana@x.com', '654321'), isFalse);
    expect(await banco.autenticar('ana@x.com', '123456'), isNotNull);
    expect(await banco.autenticar('ana@x.com', 'errada'), isNull);
  });

  test('DocumentosViewModel: criar, atualizar e excluir', () async {
    final vm = DocumentosViewModel(DocumentoStorageService());
    await vm.carregarPara('x@y.com');
    expect(vm.documentos, isEmpty);

    expect(await vm.criar(titulo: ' A ', conteudo: 'texto'), isTrue);
    expect(vm.documentos.single.titulo, 'A');
    final id = vm.documentos.single.id;

    expect(await vm.atualizar(id: id, titulo: 'B', conteudo: 'novo'), isTrue);
    expect(vm.buscar(id)!.titulo, 'B');

    // Recarrega do armazenamento: os dados continuam lá.
    await vm.recarregar();
    expect(vm.documentos.single.conteudo, 'novo');

    expect(await vm.excluir(id), isTrue);
    expect(vm.documentos, isEmpty);
  });
}
