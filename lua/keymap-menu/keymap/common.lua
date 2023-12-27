local M = {}

local Util = require("keymap-menu.util")

---@class KeymapMetadata
local example_keymap = {
  debug = { { "source:123" } },
  mode = "n",
  desc = "description",
  lhs = "c{motion}",
  rhs = "",
  expansions = { "{motion}" },
  register = false,
  operator = false,
  motion = false,
  textobject = false,
  sort = "sort",
}

---@param first_key string
---@param all_chars string
---@return string, string, boolean
local function get_next_token(first_key, all_chars)
  -- look for special sequences that we want to normalize
  if first_key == "{" then
    -- {motion}, {chars} etc
    local special, remaining = all_chars:match("^({[^}]+})(.*)")
    if special then
      return special:lower(), remaining, true
    end
  elseif first_key == "<" then
    -- <BS>, <CR>, <C-X> etc
    local special, remaining = all_chars:match("^(<[^>]+>)(.*)")
    if special then
      if special:lower() == "<nl>" then
        special = "<cr>"
      end
      return special:lower(), remaining, false
    end
  elseif first_key == "C" then
    -- CTRL-<TAB>, CTRL-K etc
    local special, remaining = all_chars:match("^CTRL%-<(.+)>(.*)")
    if not special then
      special, remaining = all_chars:match("^CTRL%-(.)(.*)")
    end
    if special then
      return "<c-" .. special:lower() .. ">", remaining, false
    end
  end
  return first_key, all_chars:sub(2), false
end

-- n	Normal
-- v	Visual and Select
-- s	Select
-- x	Visual
-- o	Operator-pending
-- i	Insert
-- c	Command-line
M.modes = { "n", "v", "s", "x", "o", "i", "c" }

---@param lhs string
---@return table<number, KeymapToken>
function M.parse_tokens(lhs)
  ---@type table<number, KeymapToken>
  local result = {}
  local all_chars = Util.strings.trim(lhs) or ""
  while all_chars and all_chars ~= "" do
    local key = all_chars:sub(1, 1)
    local next_token, remaining, expansion = get_next_token(key, all_chars)
    ---@class KeymapToken
    local token = { token = next_token, expansion = expansion }
    table.insert(result, token)
    all_chars = Util.strings.trim(remaining) or ""
  end
  return result
end

---@param tokens table<number, KeymapToken>
---@return string
function M.get_lhs_from_tokens(tokens)
  local result = ""
  for _, token in ipairs(tokens) do
    result = result .. token.token
  end
  return result
end

---@param tokens table<number, KeymapToken>
---@return table<number, string>
function M.get_expansions_from_tokens(tokens)
  ---@type table<number, string>
  local result = {}
  for _, token in ipairs(tokens) do
    if token.expansion then
      table.insert(result, token.token)
    end
  end
  return result
end

---@param from table<string, table<string, KeymapMetadata>>
---@param to table<string, table<string, KeymapMetadata>>
---@return table<string, table<string, KeymapMetadata>>
function M.merge_keymaps(from, to)
  for mode, keymaps_by_lhs in pairs(from) do
    for lhs, metadata in pairs(keymaps_by_lhs) do
      to[mode] = to[mode] or {}
      to[mode][lhs] = metadata
    end
  end
  return to
end

---@param keymaps table<string, table<string, KeymapMetadata>>
---@return table<string, table<number, KeymapMetadata>>
function M.sort_keymaps(keymaps)
  local sorted = {}
  for mode, keymaps_by_lhs in pairs(keymaps) do
    sorted[mode] = sorted[mode] or {}
    for _, metadata in pairs(keymaps_by_lhs) do
      table.insert(sorted[mode], metadata)
    end
    table.sort(sorted[mode], function(a, b)
      return a.sort < b.sort
    end)
  end
  return sorted
end

return M
