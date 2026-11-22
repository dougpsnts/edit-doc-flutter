import 'package:flutter/material.dart';

import 'models/services/banco_local_service.dart';
import 'models/services/documento_storage_service.dart';
import 'models/services/preferences_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'viewmodels/tema_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/editor_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencias = PreferencesService();
  final temaVm = TemaViewModel(preferencias);
  final authVm = AuthViewModel(
    bancoLocal: BancoLocalService(),
    preferencias: preferencias,
  );
  final documentosVm = DocumentosViewModel(DocumentoStorageService());

  // Recupera tema/fonte e sessão salvos antes de desenhar a primeira tela.
  await temaVm.carregar();
  await authVm.restaurarSessao();

  runApp(
    MeuApp(temaVm: temaVm, authVm: authVm, documentosVm: documentosVm),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({
    super.key,
    required this.temaVm,
    required this.authVm,
    required this.documentosVm,
  });

  final TemaViewModel temaVm;
  final AuthViewModel authVm;
  final DocumentosViewModel documentosVm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: temaVm,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Edit Doc Flutter',
          themeMode: temaVm.themeMode,
          theme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(temaVm.tamanhoFonte / 16),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
          initialRoute: '/',
          routes: {
            // Com sessão ativa, "/" já abre a home (ex.: após F5 na Web).
            '/': (context) => authVm.autenticado
                ? _home()
                : LoginView(authVm: authVm),
            '/cadastro': (context) =>
                CadastroView(authVm: authVm, temaVm: temaVm),
            '/home': (context) =>
                authVm.autenticado ? _home() : LoginView(authVm: authVm),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/editor') {
              // Argumento: id do documento a editar; nulo = novo documento.
              final id = settings.arguments as String?;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => authVm.autenticado
                    ? EditorView(documentosVm: documentosVm, documentoId: id)
                    : LoginView(authVm: authVm),
              );
            }
            return null;
          },
        );
      },
    );
  }

  Widget _home() =>
      HomeView(authVm: authVm, documentosVm: documentosVm, temaVm: temaVm);
}
