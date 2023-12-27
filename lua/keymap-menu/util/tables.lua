local M = {}

---@param tbl table
---@return integer
function M.size(tbl)
  local count = 0
  if tbl == nil or type(tbl) ~= "table" then
    return count
  end
  for _, _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

return M
