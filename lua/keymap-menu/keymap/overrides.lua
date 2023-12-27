local M = {}

local Common = require("keymap-menu.keymap.common")
local Strings = require("keymap-menu.util.strings")

---@type table<string, table<number, string>>
local sources = {}
local vim_keymap_set = vim.keymap.set

---@param mode string
---@param lhs string
---@param rhs function | string | nil
---@return string
local function hash(mode, lhs, rhs)
  return mode .. "~" .. lhs .. "~" .. Strings.get_function_info(rhs):lower()
end

---@param mode string
---@param lhs string
---@param rhs function | string | nil
---@param source string
local function add_source(mode, lhs, rhs, source)
  local h = hash(mode, lhs, rhs)
  sources[h] = sources[h] or {}
  table.insert(sources[h], source)
end

local function override_vim_keymap_set()
  vim.keymap.set = function(mode, lhs, rhs, opts)
    local tokens = Common.parse_tokens(lhs)
    lhs = Common.get_lhs_from_tokens(tokens)

    local info = debug.getinfo(2, "Sl")
    local source = Strings.get_function_info(rhs):lower()
    if info.source and info.currentline then
      source = info.source .. ":" .. info.currentline
    end

    if type(mode) == "table" then
      for _, m in ipairs(mode) do
        add_source(m, lhs, rhs, source)
      end
    else
      add_source(mode, lhs, rhs, source)
    end

    vim_keymap_set(mode, lhs, rhs, opts)
  end
end

---@param lhs string
---@param source table<number, string>
---@return boolean
local function ignore_keymap_overrides(lhs, rhs, desc, source)
  -- ignore nop
  if desc == "nop" then
    return true
  end

  -- ignore vscode and plugin remaps: <cmd>, <plug>
  if type(rhs) == "string" and (Strings.starts_with(rhs, "<Cmd>") or Strings.starts_with(rhs, "<Plug>")) then
    return true
  end

  -- ignore vscode-neovim remaps
  if source[#source]:match("vscode%-neovim") then
    return true
  end

  -- ignore cutlass.nvim blackhole register keymaps
  if source[#source]:match("cutlass.nvim") and Strings.starts_with(rhs, '"_') then
    return true
  end

  -- ignore any remaps of f,F,t,T
  if lhs == "f" or lhs == "F" or lhs == "t" or lhs == "T" then
    return true
  end

  return false
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
  local desc = Strings.trim(keymap.desc or ("description missing: " .. vim.inspect(source)))
  local sort = Strings.alpha_numeric_symbol_sort_string(lhs)

  -- ignore keymaps where lhs or desc is inaccurate and
  -- the default keymap metadata is already correct
  if ignore_keymap_overrides(lhs, rhs, desc, source) then
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

---@param options table
function M.setup(options)
  options = options or {}
  sources = {}
  override_vim_keymap_set()
end

function M.debug_sources()
  print(vim.inspect(sources))
end

---@param mode string
---@param lhs string
---@param rhs string
---@return table<number, string>
function M.get_source(mode, lhs, rhs)
  local h = hash(mode, lhs, rhs)
  return sources[h] or { Strings.get_function_info(rhs):lower() } -- or { "source not available" }
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
