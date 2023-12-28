local Config = require("keymap-menu.config")
local Health = require("keymap-menu.health")
local Keymap = require("keymap-menu.keymap")
local Util = require("keymap-menu.util")

---@class KeymapMenu
local M = {}

-- lua require("keymap-menu").search_normal_keymaps(function(item, idx) print(vim.inspect(item)) end)
-- use this to setup telescope display: https://github.com/nvim-telescope/telescope-ui-select.nvim/blob/master/lua/telescope/_extensions/ui-select.lua
-- lua print(vim.inspect(require("keymap-menu.keymap.overrides").get_source("n", "a")))
-- lua require("keymap-menu.keymap.overrides").debug_sources()

local function ui_select(items, prompt, on_select)
  local opts = {
    prompt = prompt,
    format_item = function(item)
      return item.label
    end,
  }
  vim.ui.select(items, opts, on_select)
end

local function ui_select_replace(items, prompt, keymap, expansion)
  ui_select(items, prompt, function(item, _)
    if item then
      keymap.label = Util.strings.replace_first(keymap.label, expansion, item.label)
    end
  end)
end

local function ui_input_replace(prompt, keymap, expansion)
  local opts = {
    prompt = prompt,
  }
  vim.ui.input(opts, function(input)
    if input then
      keymap.label = Util.strings.replace_first(keymap.label, expansion, input)
    end
  end)
end

local function feedkeys(keys, mode)
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, mode, false)
end

local function prompt_for_expansion(keymap, expansion)
  local prompt = "Pick a " .. expansion .. " for " .. keymap.label
  if expansion == "{motion}" then
    local items = Keymap.get_motion_and_textobject_items()
    ui_select_replace(items, prompt, keymap, expansion)
  else
    ui_input_replace(prompt, keymap, expansion)
  end
end

local function prompt_for_expansions(keymap)
  if keymap.metadata.expansions then
    for _, expansion in ipairs(keymap.metadata.expansions) do
      prompt_for_expansion(keymap, expansion)
    end
  end
end

---@param opts? KeymapMenuConfig
function M.setup(opts)
  Config.setup(opts)

  if not Health.check(Config.opts.health) then
    return
  end

  Keymap.setup(Config.opts.keymap)
end

--- Opens a vim.ui.select menu to pick (and feed) keymap sequences
function M.select_keymap()
  local items = Keymap.get_keymap_items("n")
  ui_select(items, "Pick a keymap", function(item, idx)
    if not item then
      return
    end

    if Config.opts.prompt_for_expansions then
      prompt_for_expansions(item)

      if Config.opts.feed_on_select then
        feedkeys(item.label, "n")
      end
    end

    Config.opts.on_select(item, idx)
  end)
end

return M
