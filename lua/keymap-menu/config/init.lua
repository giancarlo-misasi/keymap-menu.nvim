local M = {}

local Strings = require("keymap-menu.util.strings")

function M.defaults()
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
  return defaults
end

function M.default_defaults_ignore(_, _, _)
  return false
end

function M.default_overrides_ignore(lhs, rhs, desc, source)
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

--- @type KeymapMenuConfig
M.opts = {}

---@param opts? KeymapMenuConfig
function M.setup(opts)
  opts = opts or {}
  M.opts = vim.tbl_deep_extend("force", {}, M.defaults(), opts)
end

return M
