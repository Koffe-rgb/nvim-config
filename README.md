### Requirements

- `fzf` is mandatory
- `fd` for better `find` utility
- `rg` for better `grep` utility
- `dotnet` 9 for Roslyn LSP

### Features

- arrow keys are disabled in `Normal`, `Insert`, `Visual`, `Visual-Line`, `Visual-Block` modes
- use `:make` command or `<C-b>` keymap to build project. it also sends all errors into qf
- compiler set to `dotnet` when entering .cs file
- send all fzf search results into qf: `alt+a` => `enter`
