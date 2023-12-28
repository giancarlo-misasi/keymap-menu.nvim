# ⌨️ Keymap Menu

A lua plugin for Neovim that displays a searchable menu of key bindings that can be executed.

## 🪙 Features

- search keybindings by lhs
- search keybindings by description
- includes:
  - default keybinds found in index.txt
  - overrides set via vim.keymap.set
- can be opened in vscode-neovim

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "giancarlo-misasi/keymap-menu.nvim",
  priority = 1001,
  lazy = false,
  config = true
}
```

## ⚙️ Configuration

Default setup:

```lua
  ---@class KeymapMenuConfig
  local defaults = {
    feed_on_select = true,
    prompt_for_expansions = true,
    ---@type fun(item: any, idx: number)
    on_select = function(_, _) end,

    ---@class KeymapMenuHealthConfig
    health = {
      enabled = true,
    },

    ---@class KeymapMenuKeymapConfig
    keymap = {
      always_reload = true,
      ---@type table<number, { lhs: string, desc: string }>
      additional_text_objects = {},

      ---@class KeymapMenuDefaultsConfig
      defaults = {
        ---@type fun(lhs: string, desc: string, source: string): boolean
        ignore = M.default_defaults_ignore,
      },

      ---@class KeymapMenuOverridesConfig
      overrides = {
        ---@type fun(lhs: string, rhs: function | string, desc: string, source: table<number, string>): boolean
        ignore = M.default_overrides_ignore,
      },
    },
  }
```

To add a key binding to open the menu in vscode when using vscode-neovim:

```
{
    "command": "vscode-neovim.send",
    // the key sequence to activate the binding
    "key": "F4",
    // don't activate during insert mode
    "when": "editorTextFocus && neovim.mode != insert",
    // the input to send to Neovim
    "args": "<F4>"
}
```

## 🖼️ Screenshots

![Screenshot](/screenshots/menu-screenshot.png?raw=true)
