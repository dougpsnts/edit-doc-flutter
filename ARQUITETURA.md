# Arquitetura (MVVM)

## Camadas
| Camada | Arquivos | Responsabilidade |
|---|---|---|
| Model | `usuario.dart`, `documento.dart` | Dados e conversão `toMap()`/`fromMap()` |
| Services (dentro de models) | `preferences_service`, `banco_local_service`, `documento_storage_service`, `storage_utils` | Único ponto de acesso ao `shared_preferences` |
| ViewModel | `auth_`, `documentos_`, `tema_viewmodel` | Estado (`ChangeNotifier`), regras de negócio, `notifyListeners()` |
| View | `login_`, `cadastro_`, `home_`, `editor_view` | Somente interface; observa VMs com `ListenableBuilder` |
| main | `main.dart` | Cria os VMs, `ThemeData` claro/escuro, rotas nomeadas |

## Services sem duplicação
- `banco_local_service.dart`: usuários (chave `usuarios`).
- `documento_storage_service.dart`: documentos (chave `documentos_<email>`, uma lista por usuário).
- `preferences_service.dart`: tema, fonte e sessão (`sessao_email`).

## Persistência
Listas são convertidas com `toMap()` → `jsonEncode()` e gravadas como String; na leitura, `jsonDecode()` → `fromMap()`, tudo com `async/await`. Dado inexistente ou JSON inválido resulta em lista vazia; itens corrompidos são descartados; falha de gravação lança `StorageException`, tratada nos ViewModels. Na Web o `shared_preferences` usa `localStorage`, por isso os dados sobrevivem ao F5.

## Fluxo
View → ViewModel (método) → Service → shared_preferences; o ViewModel atualiza seu estado e notifica; a View reconstrói.

## Rotas
`/` (login, ou home se houver sessão), `/cadastro`, `/home`, `/editor` (argumento: id do documento; ausente = novo).

## Limitações da autenticação local
Não há servidor. Usuários e **senhas ficam em texto simples** no armazenamento do navegador/dispositivo, legíveis por quem tiver acesso a ele. Serve para a atividade; não é um sistema seguro de autenticação. Uma versão real exigiria back-end com hash de senha e tokens.
