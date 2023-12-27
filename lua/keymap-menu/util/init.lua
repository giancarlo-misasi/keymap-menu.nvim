local M = {}

M.strings = require("keymap-menu.util.strings")
M.files = require("keymap-menu.util.files")
M.tables = require("keymap-menu.util.tables")

function M.measure_nanoseconds(func, ...)
  local start_time = vim.loop.hrtime()
  func(...)
  local end_time = vim.loop.hrtime()
  return end_time - start_time
end

function M.measure_milliseconds(func, ...)
  return M.measure_nanoseconds(func, ...) / 1e6
end

return M
