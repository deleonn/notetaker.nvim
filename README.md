## Installation

### [Packer](https://github.com/wbthomason/packer.nvim)

```
use 'deleonn/notetaker.nvim'
```

## Configuration

Before you create notes, you need to provide the path where you want to store your notes:

```
use {
    'deleonn/notetaker.nvim',
    config = function()
        require('notetaker').set_notes_dir(vim.fn.expand('~/Notes'))
    end
}
```

## Usage

### Commands

- `:NoteTakerCreate`: Creates a new note. If you have configured a notes directory, this command will create a new note file in that directory.

### Keybindings

The plugin offers a default keybinding for creating a new note to streamline your note-taking process. However, you can easily customize this keybinding to suit your preferences.

#### Default Keybinding

- `<Leader>ntc` : Creates a new note.
- `<Leader>nts` : Shows all your notes. Hit enter on an entry to open a new pane with the note.

#### Custom Keybinding

To customize the keybinding, map your preferred key combination to the `:NoteTakerCreate` command in your Neovim configuration file. For example, to use `<Leader>cn` instead of the default, add the following line:

```vim
nnoremap <Leader>ntc :NoteTakerCreate<CR>
nnoremap <Leader>nts :NoteTakerShow<CR>
```

Or if you prefer lua:

```lua
vim.api.nvim_set_keymap('n', '<Leader>ntc', ':NoteTakerCreate<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>nts', ':NoteTakerShow<CR>', { noremap = true, silent = true })
```
