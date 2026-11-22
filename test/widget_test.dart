import 'package:edit_doc_flutter/main.dart';
import 'package:edit_doc_flutter/models/services/banco_local_service.dart';
import 'package:edit_doc_flutter/models/services/documento_storage_service.dart';
import 'package:edit_doc_flutter/models/services/preferences_service.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';
import 'package:edit_doc_flutter/viewmodels/tema_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('sem sessão, o app abre na tela de login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = PreferencesService();

    await tester.pumpWidget(
      MeuApp(
        temaVm: TemaViewModel(preferencias),
        authVm: AuthViewModel(
          bancoLocal: BancoLocalService(),
          preferencias: preferencias,
        ),
        documentosVm: DocumentosViewModel(DocumentoStorageService()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
  });
}
