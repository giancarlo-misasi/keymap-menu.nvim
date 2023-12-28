local M = {}

local Common = require("keymap-menu.keymap.common")
local Defaults = require("keymap-menu.keymap.defaults")
local Overrides = require("keymap-menu.keymap.overrides")
local Util = require("keymap-menu.util")

local function load_check()
  if not M.loaded or M.opts.always_reload then
    M.load()
  end
end

---@param items table<number, KeymapMetadata>
---@param metadata KeymapMetadata
local function insert_keymap_as_item(items, metadata)
  ---@class KeymapMenuItem
  local item = {
    label = metadata.lhs,
    detail = metadata.desc,
    metadata = metadata,
  }
  table.insert(items, item)
end

M.loaded = false

---@type table<string, table<number, KeymapMetadata>>
M.keymaps = {}

---@type table<number, KeymapMetadata>
M.motions = {}

---@type table<number, KeymapMetadata>
M.textobjects = {}

---@param opts KeymapMenuKeymapConfig
function M.setup(opts)
  M.opts = opts
  Defaults.setup(opts.defaults)
  Overrides.setup(opts.overrides)
end

function M.load()
  ---@type table<string, table<string, KeymapMetadata>>
  local all = {}
  Common.merge_keymaps(Defaults.get_default_keymaps(), all)
  Common.merge_keymaps(Overrides.get_override_keymaps(), all)
  M.keymaps = Common.sort_keymaps(all)

  -- motions and textobjects
  M.motions = {}
  M.textobjects = {}
  for _, keymaps in pairs(M.keymaps) do
    for _, keymap in ipairs(keymaps) do
      if keymap.motion then
        table.insert(M.motions, keymap)
      end
      if keymap.textobject then
        table.insert(M.textobjects, keymap)
      end
    end
  end

  -- add additional textobjects
  for _, textobject in ipairs(M.opts.additional_text_objects) do
    table.insert(M.textobjects, {
      debug = { "additional_text_objects" },
      mode = "textobjects",
      desc = Util.strings.trim(textobject.lhs),
      lhs = textobject.lhs,
      expansions = {},
      register = false,
      operator = false,
      motion = false,
      textobject = true,
      sort = Util.strings.alpha_numeric_symbol_sort_string(textobject.lhs),
    })
  end

  M.loaded = true
end

---@param mode string
---@return table<number, KeymapMenuItem>
function M.get_keymap_items(mode)
  load_check()

  local items = {}
  for _, metadata in ipairs(M.keymaps[mode]) do
    insert_keymap_as_item(items, metadata)
  end
  return items
end

---@return table<number, KeymapMenuItem>
function M.get_motion_items()
  load_check()

  local items = {}
  for _, metadata in ipairs(M.motions) do
    insert_keymap_as_item(items, metadata)
  end
  return items
end

---@return table<number, KeymapMenuItem>
function M.get_textobject_items()
  load_check()

  local items = {}
  for _, metadata in ipairs(M.textobjects) do
    insert_keymap_as_item(items, metadata)
  end
  return items
end

---@return table<number, KeymapMenuItem>
function M.get_motion_and_textobject_items()
  load_check()

  local items = {}
  for _, metadata in ipairs(M.motions) do
    insert_keymap_as_item(items, metadata)
  end
  for _, metadata in ipairs(M.textobjects) do
    insert_keymap_as_item(items, metadata)
  end
  return items
end

return M
