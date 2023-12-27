local plugin = require("keymap-menu.keymap")

describe("setup", function()
  it("get_keymap_items works", function()
    local actual = plugin.get_keymap_items("n")
    assert.are.equals(338, #actual)
  end)
end)
