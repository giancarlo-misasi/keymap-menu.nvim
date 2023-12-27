local plugin = require("keymap-menu.util.strings")

describe("setup", function()
  it("replace_first works", function()
    local actual = plugin.replace_first("big big book", "big", "a")
    assert.are.equals("a big book", actual)
  end)
end)
