### Requirements

- `fzf` is mandatory
- `fd` for a better `find` utility
- `rg` for a better `grep` utility
- .NET 9 for Roslyn LSP

### Features

- Arrow keys are disabled in `Normal`, `Insert`, `Visual`, `Visual-Line`, `Visual-Block` modes.
- Use the `:make` command or the `<C-b>` keymap to build the project. It also sends all errors to quickfix list.
- The compiler is set to `dotnet` when entering a .cs file.
- Send all fzf search results into quickfix list: `alt+a` => `enter`

### Sources

Here's a list of the sources I used to learn about Neovim and its configuration. In this particular order:

- ["Understanding Neovim" by Vhyrro](https://youtube.com/playlist?list=PLx2ksyallYzW4WNYHD9xOFrPRYGlntAft&si=QMgGML3WbBQIA3VH)
- ["Neovim" by MrJakob](https://youtube.com/playlist?list=PLy68GuC77sURrnMNi2XR1h58m674KOvLG&si=o8NTsbctPsoOHLcY)
- ["Setting up C# in Neovim (from scratch)" by ramboe (and some other videos too)](https://youtube.com/playlist?list=PLh93Lf4i9RhyN5xRNxpZD4HjhVHhm9GHZ&si=vAX1nGzSSVIsmanB)
- ThePrimeagen (more like inspiration)

Huge thanks to them!
