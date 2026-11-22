# Edit Doc Flutter

Aplicativo de gerenciamento e edição de documentos feito em **Flutter/Dart** com arquitetura **MVVM**. Atividade de Desenvolvimento Mobile Nativo.

- Repositório: https://github.com/dougpsnts/edit-doc-flutter
- GitHub Pages (após publicar): https://dougpsnts.github.io/edit-doc-flutter/

## Funcionalidades
- Cadastro e login de usuários com validação de nome, e-mail e senha (autenticação **local**, ver limitações em `ARQUITETURA.md`).
- Sessão persistida: ao atualizar a página (F5) o usuário continua logado.
- CRUD de documentos (criar, listar, editar, excluir com confirmação), por usuário.
- Tema claro/escuro e tamanho da fonte persistentes, aplicados imediatamente.
- Persistência com `shared_preferences` + JSON (funciona na Web e no Android; sem SQLite).

## Tecnologias
Flutter, Dart, Material 3, `shared_preferences`, `ChangeNotifier`/`ListenableBuilder`.

## Estrutura
```
lib/
├── main.dart                      # inicialização, temas, rotas nomeadas
├── models/
│   ├── usuario.dart, documento.dart
│   └── services/
│       ├── preferences_service.dart        # tema, fonte, sessão
│       ├── banco_local_service.dart        # usuários (JSON)
│       ├── documento_storage_service.dart  # documentos (JSON)
│       └── storage_utils.dart              # JSON/erros compartilhados
├── viewmodels/  auth_, documentos_, tema_viewmodel.dart
├── views/       login_, cadastro_, home_, editor_view.dart
└── utils/       validadores.dart, formatadores.dart
```

## Executar
```bash
flutter pub get
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0   # Codespaces
flutter analyze && flutter test
```

## Gerar o APK
```bash
flutter build apk --release --target-platform android-arm64
# saída: build/app/outputs/flutter-apk/app-release.apk
```
`android/gradle.properties` já usa `-Xmx1536m` e `org.gradle.daemon=false` (ajuste recomendado pela atividade).

## Publicar na Web (GitHub Pages)
```bash
./scripts/publicar_web.sh
```
Depois, em *Settings → Pages*: branch `gh-pages`, pasta `/ (root)`.
