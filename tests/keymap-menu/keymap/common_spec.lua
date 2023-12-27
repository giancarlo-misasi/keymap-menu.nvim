local plugin = require("keymap-menu.keymap.common")

local Util = require("keymap-menu.util")

describe("setup", function()
  it("parse_token chars only works", function()
    local actual = plugin.parse_tokens("abc")
    assert.are.equals("a", actual[1].token)
    assert.are.equals(false, actual[1].expansion)
    assert.are.equals("b", actual[2].token)
    assert.are.equals(false, actual[2].expansion)
    assert.are.equals("c", actual[3].token)
    assert.are.equals(false, actual[3].expansion)
  end)

  it("parse_token with {} sequence works", function()
    local actual = plugin.parse_tokens("c{MOTION}")
    assert.are.equals("c", actual[1].token)
    assert.are.equals(false, actual[1].expansion)
    assert.are.equals("{motion}", actual[2].token)
    assert.are.equals(true, actual[2].expansion)
  end)

  it("parse_token with <> sequence works", function()
    local actual = plugin.parse_tokens("g<C-P>")
    assert.are.equals("g", actual[1].token)
    assert.are.equals(false, actual[1].expansion)
    assert.are.equals("<c-p>", actual[2].token)
    assert.are.equals(false, actual[2].expansion)
  end)

  it("parse_token with CTRL sequence works", function()
    local actual = plugin.parse_tokens("zCTRL-<TAB>")
    assert.are.equals("z", actual[1].token)
    assert.are.equals(false, actual[1].expansion)
    assert.are.equals("<c-tab>", actual[2].token)
    assert.are.equals(false, actual[2].expansion)
  end)
end)
