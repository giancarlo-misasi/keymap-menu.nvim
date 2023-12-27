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
local function search_expansion(item, expansion)
  if expansion == "{motion}" then
    -- TODO: Prompt
    item.label = Util.strings.replace_first(item.label, "{motion}", "iw")
  end
end

local function search_expansions(item)
  if item.metadata.expansions then
    for _, expansion in ipairs(item.metadata.expansions) do
      search_expansion(item, expansion)
    end
  end
end

---@param opts? KeymapMenuConfig
function M.setup(opts)
  if not Health.check() then
    return
  end
  Keymap.setup(opts or {})
end

---@param on_select function<any, number>
function M.search_normal_keymaps(on_select)
  local items = Keymap.get_keymap_items("n")
  vim.ui.select(items, {
    prompt = "Filter the keymaps by keys or descriptions:",
    format_item = function(item)
      return item.label
    end,
  }, function(item, idx)
    if item then
      search_expansions(item)
      on_select(item, idx)
    end
  end)
end

-- function M.debug_keymaps()
--   -- TODO: Show source info
-- end

return M
