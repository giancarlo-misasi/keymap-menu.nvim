# ⌨️ Keymap Menu

A lua plugin for Neovim that displays a searchable menu of key bindings that can be executed.

## 🪙 Features

- search keybindings by lhs
- search keybindings by description
- includes:
  - default keybinds found in index.txt
  - overrides set via vim.keymap.set

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "giancarlo-misasi/keymap-menu.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}
```

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "giancarlo-misasi/keymap-menu.nvim",
  config = function()
    require("keymap-menu").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}
```
