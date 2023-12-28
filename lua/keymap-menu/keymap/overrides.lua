local M = {}

local Common = require("keymap-menu.keymap.common")
local Strings = require("keymap-menu.util.strings")

---@param mode string
---@param lhs string
---@param rhs function | string | nil
---@return string
local function hash(mode, lhs, rhs)
  return mode .. "~" .. lhs .. "~" .. Strings.get_function_info(rhs):lower()
end

---@param rhs function | string | nil
---@return string
local function default_source(rhs)
  return Strings.get_function_info(rhs):lower()
end

---@param info { source?: string, currentline?: number }
---@param rhs function | string | nil
---@return string
local function build_source(info, rhs)
  local source = default_source(rhs)
  if info.source and info.currentline then
    source = info.source .. ":" .. info.currentline
  end
  return source
end

---@param mode table | string
---@param lhs string
---@param rhs function | string | nil
---@param source string
local function add_source(mode, lhs, rhs, source)
  if type(mode) == "table" then
    for _, m in ipairs(mode) do
      add_source(m, lhs, rhs, source)
    end
  else
    local h = hash(mode, lhs, rhs)
    M.sources[h] = M.sources[h] or {}
    table.insert(M.sources[h], source)
  end
end

---@param mode string
---@param keymap any
---@param results table<string, table<string, KeymapMetadata>>
local function parse_override_keymap(mode, keymap, results)
  local lhs = Strings.trim(keymap.lhs)
  if lhs == nil or Strings.starts_with(lhs, "<Plug>") then
    return
  end

  -- make the lhs format uniform (don't expect expansions)
  local tokens = Common.parse_tokens(lhs)
  lhs = Common.get_lhs_from_tokens(tokens)
  assert(#Common.get_expansions_from_tokens(tokens) == 0, "Overrides should not have expansions")

  -- determine override attributes
  local rhs = keymap.rhs or keymap.callback
  local source = M.get_source(mode, lhs, rhs)
  local desc = Strings.trim(keymap.desc or ("description missing: " .. vim.inspect(source))) or ""
  local sort = Strings.alpha_numeric_symbol_sort_string(lhs)

  -- check for excluded keymaps
  if M.opts.ignore(lhs, rhs, desc, source) then
    return
  end

  -- update the keymap collection
  local existing = results[mode][lhs]
  if not existing then
    results[mode][lhs] = {
      debug = source,
      mode = mode,
      desc = desc,
      lhs = lhs,
      rhs = rhs,
      expansions = {},
      register = false,
      operator = false,
      motion = false,
      textobject = false,
      sort = sort,
    }
    return
  end

  -- otherwise, update the debug information
  for _, s in ipairs(source) do
    table.insert(existing.debug, s)
  end

  -- if there is no rhs, this is only an impl change, so leave metadata unchanged
  if rhs == nil or rhs == "" then
    return
  end

  -- update the existing metadata
  -- don't change metadata for builtin changes - only override rhs for those
  existing.rhs = rhs
  if desc ~= "Nvim builtin" then
    existing.desc = desc
    existing.register = false
    existing.operator = false
    existing.motion = false
    existing.textobject = false
    existing.sort = sort
  end
end

---@type table<string, table<number, string>>
M.sources = {}
M.vim_keymap_set = vim.keymap.set

---@param opts KeymapMenuOverridesConfig
function M.setup(opts)
  M.opts = opts
  M.sources = {}
  vim.keymap.set = function(mode, lhs, rhs, opts)
    local tokens = Common.parse_tokens(lhs)
    lhs = Common.get_lhs_from_tokens(tokens)
    M.vim_keymap_set(mode, lhs, rhs, opts)
    local source = build_source(debug.getinfo(2, "Sl"), rhs)
    add_source(mode, lhs, rhs, source)
  end
end

---@param mode string
---@param lhs string
---@param rhs string
---@return table<number, string>
function M.get_source(mode, lhs, rhs)
  local h = hash(mode, lhs, rhs)
  return M.sources[h] or { default_source(rhs) }
end

---@return table<string, table<string, KeymapMetadata>>
function M.get_override_keymaps()
  local results = {}
  for _, mode in ipairs(Common.modes) do
    results[mode] = results[mode] or {}
    local all = {
      vim.api.nvim_get_keymap(mode),
      vim.api.nvim_buf_get_keymap(0, mode),
    }
    for _, keymaps in ipairs(all) do
      for _, keymap in ipairs(keymaps) do
        parse_override_keymap(mode, keymap, results)
      end
    end
  end
  return results
end

return M
