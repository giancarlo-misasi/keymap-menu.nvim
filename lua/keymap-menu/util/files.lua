local M = {}

---@param path string
---@return boolean
function M.path_exists(path)
  if path == nil then
    return false
  end
  return vim.loop.fs_stat(path)
end

---@param path string
---@return table
function M.read_lines(path)
  local lines = {}
  if not M.path_exists(path) then
    return lines
  end
  local file = io.open(path, "r")
  if file then
    for line in file:lines() do
      table.insert(lines, line)
    end
    file:close()
  end
  return lines
end

return M
