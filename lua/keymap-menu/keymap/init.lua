local M = {}

local Common = require("keymap-menu.keymap.common")
local Defaults = require("keymap-menu.keymap.defaults")
local Overrides = require("keymap-menu.keymap.overrides")

local function create_telescope_items(keymaps)
  local items = {}
  for _, metadata in ipairs(keymaps) do
    table.insert(items, { label = metadata.lhs, detail = metadata.desc, metadata = metadata })
  end
  return items
end

local function create_vscode_items(keymaps)
  local items = {}
  for _, metadata in ipairs(keymaps) do
    table.insert(items, { label = metadata.lhs, detail = metadata.desc, metadata = metadata })
  end
  return items
end

-- local function send(keys, mode)
--     keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
--     vim.api.nvim_feedkeys(keys, mode, false)
-- end

---@param options table
function M.setup(options)
  options = options or {}
  Overrides.setup(options)
end

function M.get_keymap_items(mode)
  ---@type table<string, table<string, KeymapMetadata>>
  local all = {}
  Common.merge_keymaps(Defaults.get_default_keymaps(), all)
  Common.merge_keymaps(Overrides.get_override_keymaps(), all)

  ---@type table<number, KeymapMetadata>
  local keymaps = Common.sort_keymaps(all)[mode]
  if vim.g.vscode then
    return create_vscode_items(keymaps)
  else
    return create_telescope_items(keymaps)
  end
end

return M
