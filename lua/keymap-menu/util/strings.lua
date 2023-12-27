local M = {}

---@param str string
---@return string
function M.alpha_numeric_symbol_sort_string(str)
  if str == nil then
    return nil
  end
  local sorted_str = ""
  for i = 1, #str do
    local byteValue = str:byte(i)
    if byteValue >= 97 and byteValue <= 122 then -- shift lower alpha to 0
      sorted_str = sorted_str .. string.char(byteValue - 97)
    elseif byteValue >= 65 and byteValue <= 90 then -- shift upper alpha to 26
      sorted_str = sorted_str .. string.char(byteValue - 65 + 26)
    elseif byteValue >= 48 and byteValue <= 57 then -- shift numbers to 52
      sorted_str = sorted_str .. string.char(byteValue - 48 + 52)
    elseif byteValue >= 32 and byteValue <= 47 then -- shift symbols1 to 62
      sorted_str = sorted_str .. string.char(byteValue - 32 + 62)
    elseif byteValue >= 58 and byteValue <= 64 then -- shift symbols2 to 78
      sorted_str = sorted_str .. string.char(byteValue - 58 + 78)
    elseif byteValue >= 91 and byteValue <= 96 then -- shift symbols3 to 85
      sorted_str = sorted_str .. string.char(byteValue - 91 + 85)
    elseif byteValue >= 123 and byteValue <= 126 then -- shift symbols4 to 91
      sorted_str = sorted_str .. string.char(byteValue - 123 + 91)
      -- else                                         -- ignore any other characters
    end
  end
  return sorted_str
end

---@param str string
---@param starts_with string
---@return boolean
function M.starts_with(str, starts_with)
  if str == nil or starts_with == nil then
    return false
  end
  return string.sub(str, 1, string.len(starts_with)) == starts_with
end

---@param str string
---@return string | nil
function M.trim(str)
  if str == nil then
    return nil
  end
  return str:match("^%s*(.-)%s*$")
end

---@param str string
---@param find string
---@param replace string
---@return string | nil
function M.replace_first(str, find, replace)
  if str == nil or find == nil or replace == nil then
    return nil
  end
  local result, _ = string.gsub(str, find, replace, 1)
  return result
end

---@param func function | string | nil
---@return string
function M.get_function_info(func)
  if func == nil or type(func) == "string" then
    return func or ""
  end
  local success, info = pcall(debug.getinfo, func, "Snl")
  if success and info then
    return info.source .. ":" .. info.linedefined
  else
    return string.dump(func) or ""
  end
end

return M
