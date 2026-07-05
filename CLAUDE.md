# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Run `stow .` from the repo root to symlink everything into `$HOME`. The `.stow-local-ignore` file excludes git metadata and README/LICENSE files from being stowed.

## Repository Layout

```
Dotfiles/
├── .tmux.conf          # tmux config
├── .wezterm.lua        # WezTerm terminal config
├── .zshrc              # Zsh config (Oh My Zsh + Powerlevel10k)
└── .config/
    └── nvim/           # Neovim config (Lua)
```

## Neovim Architecture

Entry point is `init.lua`, which loads three top-level modules:

- `lua/jake/core/` — editor options and base keymaps (no plugins)
- `lua/jake/lazy.lua` — bootstraps lazy.nvim and imports all plugin specs
- `lua/jake/lsp.lua` — LSP `LspAttach` autocmd with keymaps and diagnostic signs

Plugins live in `lua/jake/plugins/` — each file returns a lazy.nvim spec table. LSP-specific plugin specs are in `lua/jake/plugins/lsp/`. The `after/lsp/` directory holds per-language LSP config overrides (Neovim 0.11+ `vim.lsp.config` style).

### Plugin Manager

lazy.nvim. To update the lockfile: `:Lazy update`. The lockfile is `lazy-lock.json`.

### LSP Stack

- **Server management**: mason.nvim + mason-lspconfig (auto-installs servers listed in `lua/jake/plugins/lsp/mason.lua`)
- **Capabilities**: cmp-nvim-lsp provides completion capabilities, applied globally via `vim.lsp.config("*", ...)`
- **Formatting**: conform.nvim (format-on-save; `<leader>mp` to format manually)
  - Web (JS/TS/CSS/HTML/JSON/YAML/GraphQL/Svelte): prettier
  - Lua: stylua (config: `.stylua.toml`)
  - Python: isort + black
- **Linting**: nvim-lint (`lua/jake/plugins/linting.lua`)
- **Tools installed via mason**: prettier, stylua, isort, black, pylint, eslint_d

### Key Keymaps (leader = `<Space>`)

| Key | Action |
|-----|--------|
| `jk` | Exit insert mode |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fs` | Live grep (Telescope) |
| `<leader>fr` | Recent files |
| `<leader>fc` | Grep string under cursor |
| `gd` | Go to definition |
| `gR` | LSP references |
| `K` | Hover docs |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>d` | Line diagnostics |
| `<leader>D` | Buffer diagnostics |
| `<leader>mp` | Format file/range |
| `<leader>rs` | Restart LSP |

### tmux (prefix: `C-a`)

- `|` / `-` — horizontal / vertical split
- `h/j/k/l` — resize pane
- `m` — zoom pane toggle
- Session persistence via tmux-resurrect + tmux-continuum

## Adding a New Plugin

Create a file in `lua/jake/plugins/` returning a lazy.nvim spec. It will be auto-imported by `lazy.lua` via `{ import = "jake.plugins" }`.

## Adding a New LSP Server

1. Add the server name to `ensure_installed` in `lua/jake/plugins/lsp/mason.lua`
2. If the server needs custom config, create `after/lsp/<server_name>.lua`
