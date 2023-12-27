local plugin = require("keymap-menu.keymap.overrides")

describe("setup", function()
  it("setup and get_source works", function()
    local expected = debug.getinfo(1, "Sl").source .. ":7"
    plugin.setup()
    vim.keymap.set("n", "c", "c")

    local actual = plugin.get_source("n", "c", "c")
    assert.are.equals(1, #actual)
    assert.are.equals(expected, actual[1])
  end)
end)
