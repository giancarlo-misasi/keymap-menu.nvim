local M = {}

local Util = require("keymap-menu.util")
local Common = require("keymap-menu.keymap.common")

local index_path = "doc/index.txt"
local mode_tag_prefixes = { ["i_"] = "i", ["v_"] = "v" }
local ignored_mode_tag_prefixes = { "complete_", "CTRL-W_", "c_", "o_" }
local sections = {
  insert_mode = "1. Insert mode",
  normal_mode = "2. Normal mode",
  text_objects = "2.1 Text objects",
  window_commands = "2.2 Window commands",
  square_bracket_commands = "2.3 Square bracket commands",
  g_commands = "2.4 Commands starting with 'g'",
  z_commands = "2.5 Commands starting with 'z'",
  operator_pending_mode = "2.6 Operator-pending mode",
  visual_mode = "3. Visual mode",
  command_line_editing = "4. Command-line editing",
  terminal_mode = "5. Terminal mode",
  ex_commands = "6. EX commands",
}

---@param section string
---@param line string
---@return string
local function parse_section(section, line)
  for _, pattern in pairs(sections) do
    if string.find(line, pattern) then
      return pattern
    end
  end
  return Util.strings.trim(section) or ""
end

---@param tag string
---@return string | nil
local function parse_mode(tag)
  -- ignore unsupported tags / modes
  -- ignore commands, but capture the mapping to enter commands
  if tag == nil or tag == "" or (Util.strings.starts_with(tag, ":") and tag ~= ":") then
    return nil
  end
  for _, ignored_prefix in ipairs(ignored_mode_tag_prefixes) do
    if Util.strings.starts_with(tag, ignored_prefix) then
      return nil
    end
  end
  -- find the mode using the tag
  for tag_prefix, mode in pairs(mode_tag_prefixes) do
    if Util.strings.starts_with(tag, tag_prefix) then
      return mode
    end
  end
  -- otherwise, it is expected to be a normal mode command
  return "n"
end

---@param path string
---@param lines table<number, string>
---@param section string
---@param line string
---@param line_number number
---@return string, number, KeymapMetadata | nil
local function parse_default_keymap_line(path, lines, section, line, line_number)
  -- check if the section has changed
  section = parse_section(section, line)

  -- parse the mapping
  local tag, char, note, desc = line:match("|([^|]+)|[\t]+([^\t]+)[\t%s]+([12,%s]*)(.*)")
  if not tag or not char or not desc then
    return section, line_number
  end
  note = Util.strings.trim(note)

  -- ignore tags which we don't want/need to parse
  -- skip the 4 digraph mappings which we don't care about and need special handling
  -- skip [,],g,z {char} which will have subsequent entries for each valid {char}
  if
    tag == "'cedit'"
    or (tag == ":" and desc == "nothing")
    or tag == "count"
    or tag == "CTRL-W"
    or char:match("{char1}")
    or char:match("[%[%]gz]{char}")
  then
    return section, line_number
  end

  -- parse the mode
  local mode = parse_mode(tag)
  if not mode then
    return section, line_number
  end

  -- check for register and remove from lhs
  local register = char:match('%["x%]')
  if register then
    register = true
    char = string.sub(char, 5)
  end

  -- make the lhs format uniform and extract any expansions like {motion}
  local tokens = Common.parse_tokens(char)
  local lhs = Common.get_lhs_from_tokens(tokens)
  local expansions = Common.get_expansions_from_tokens(tokens)
  local source = path .. ":" .. line_number

  -- check for excluded keymaps
  if M.opts.ignore(lhs, desc, source) then
    return section, line_number
  end

  -- parse the full description
  local nextLine = lines[line_number + 1]
  while nextLine and string.match(nextLine, "^%s") do
    desc = Util.strings.trim(desc) .. " " .. Util.strings.trim(nextLine)
    line_number = line_number + 1
    nextLine = lines[line_number + 1]
  end

  -- only include motions from normal mode
  local motion = mode == "n" and note == "1" and not Util.strings.starts_with(lhs, "<c-")

  -- textobjects appear twice
  -- when we parse them treat them as normal mode mappings
  local textobject = section == sections.text_objects and mode == "v"
  if textobject then
    mode = "textobjects"
  end

  return section,
    line_number,
    {
      debug = { source },
      mode = mode,
      desc = Util.strings.trim(desc),
      lhs = lhs,
      expansions = expansions,
      register = register,
      operator = not not expansions,
      motion = motion,
      textobject = textobject,
      sort = Util.strings.alpha_numeric_symbol_sort_string(lhs),
    }
end

---@param opts KeymapMenuDefaultsConfig
function M.setup(opts)
  M.opts = opts
end

---@return table<string, table<string, KeymapMetadata>>
function M.get_default_keymaps()
  local results = {}
  local path = vim.api.nvim_get_runtime_file(index_path, true)[1]
  local lines = Util.files.read_lines(path)
  local section = ""
  local keymap = nil
  for line_number = 1, #lines do
    local line = lines[line_number]
    if line then
      section, line_number, keymap = parse_default_keymap_line(path, lines, section, line, line_number)
      if keymap then
        results[keymap.mode] = results[keymap.mode] or {}
        results[keymap.mode][keymap.lhs] = keymap
      end
    end
  end
  return results
end

return M
