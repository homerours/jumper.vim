# Jumper.vim

Vim plugin for [Jumper](https://github.com/homerours/jumper).

## Installation

Install `homerours/jumper.vim` using your favorite plugin manager (this requires `junegunn/fzf` plugin). Using for instance [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'homerours/jumper.vim'
```

## Usage

Use `:Zf <query>` to open the file matching a given `<query>` or `:Z <query>` to change the current working directory.

The default bindings for fuzzy-finding are
- `Ctrl-Y` : find folders.
- `Ctrl-U` : find files.
- `<leader>fu` : live grep files (`bat` and `ripgrep` required).

They can changed, using the functions `JumperFiles`, `JumperFolders` and `JumperFu`, e.g.
```vim
nnoremap <C-u> :JumperFiles<CR>
nnoremap <C-y> :JumperFolders<CR>
nnoremap <leader>fu :JumperFu<CR>
```
