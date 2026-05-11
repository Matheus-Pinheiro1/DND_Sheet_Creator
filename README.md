# D&D Character Sheet

Flutter app para criar, editar e consultar fichas de Dungeons & Dragons 5e,
com foco nas regras de 2024. O app tambem inclui ferramentas de combate,
monstros, referencias, opcoes homebrew e calculos de equipamento.

## Stack

- Flutter
- Riverpod para estado
- GoRouter para rotas
- Hive para armazenamento local
- JSON local em `assets/data/2024`

## Como rodar

```bash
flutter pub get
flutter run
```

Para checar problemas estaticos:

```bash
dart analyze lib
```

Se alterar modelos Hive ou arquivos com `*.g.dart`, gere os adapters de novo:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Estrutura principal

- `lib/app.dart`: rotas e tema global.
- `lib/main.dart`: carregamento de dados locais e inicializacao do Hive.
- `lib/data`: modelos, repositorios, loaders e services de regra.
- `lib/providers`: estado compartilhado do app.
- `lib/presentation`: telas, abas, dialogs e widgets.
- `assets/data/2024`: dados usados pelo app.
