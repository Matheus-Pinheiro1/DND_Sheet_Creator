# D&D Character Sheet

App Flutter para montar e consultar fichas de D&D 5e, com foco nas regras de
2024. A ideia e deixar o basico rapido de usar na mesa: personagem, magias,
equipamentos, monstros e encontros em um lugar so.

## O que tem

- Criacao e edicao de personagens.
- Progressao de nivel, escolhas de classe, magias, pericias e equipamentos.
- Compendio de monstros com busca e filtros.
- Controle de encontros com iniciativa, HP, condicoes e acoes de monstros.
- Opcoes homebrew para especie, antecedente e classe.

## Tecnologias

- Flutter.
- Riverpod.
- GoRouter.
- Hive.
- Dados locais em JSON dentro de `assets/data/2024`.

## Como rodar

```bash
flutter pub get
flutter run
```

Para checar problemas estaticos:

```bash
dart analyze lib
```

Se mexer em modelos Hive ou arquivos com `*.g.dart`, rode:

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

## Observacao

Projeto fan-made para estudo e uso pessoal. D&D e todos os dados usados nesse aplicativo pertencem a Wizards of the
Coast.
