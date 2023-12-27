local plugin = require("keymap-menu.keymap.defaults")

local Util = require("keymap-menu.util")

describe("setup", function()
  it("get_default_keymaps works", function()
    local actual = plugin.get_default_keymaps()
    assert.are.equals(3, Util.tables.size(actual))

    local normal = actual["n"]
    assert.is_not_nil(normal)
    assert.are.equals(338, Util.tables.size(normal))

    local insert = actual["i"]
    assert.is_not_nil(insert)
    assert.are.equals(83, Util.tables.size(insert))

    local visual = actual["v"]
    assert.is_not_nil(visual)
    assert.are.equals(81, Util.tables.size(visual))
  end)

  it("keymap has correct structure and values", function()
    local actual = plugin.get_default_keymaps()
    local keymap = actual["n"]["c{motion}"]
    assert.is_not_nil(keymap)

    assert.are.equals("index.txt", keymap.debug[1]:match("index.txt"))
    assert.are.equals("n", keymap.mode)
    assert.are.equals("delete Nmove text [into register x] and start insert", keymap.desc)
    assert.are.equals("c{motion}", keymap.lhs)
    assert.are.equals("{motion}", keymap.expansions[1])
    assert.are.equals(true, keymap.register)
    assert.are.equals(true, keymap.operator)
    assert.are.equals(false, keymap.motion)
    assert.are.equals(false, keymap.textobject)
    assert.are.equals(Util.strings.alpha_numeric_symbol_sort_string("c{motion}"), keymap.sort)
  end)

  it("check runtime duration", function()
    local ms = Util.measure_milliseconds(plugin.get_default_keymaps)
    assert(ms < 25, "should be faster than 25ms, but was " .. ms .. "ms")
  end)
end)
