local plugin = require("keymap-menu")
local selected_idx = 1

-- test setup
plugin.setup({
  keymap = {
    always_reload = true,
  },
  on_select = function(item, idx)
    vim.g._result_item = item
    vim.g._result_idx = idx
  end,
})

local function before_each()
  selected_idx = 1
  vim.g._result_item = nil
  vim.g._result_idx = nil
end

-- mocking
local function override_select(target_lhs)
  vim.ui.select = function(items, opts, on_choice)
    for idx, item in ipairs(items) do
      if item.metadata.lhs == target_lhs then
        selected_idx = idx
        break
      end
    end
    on_choice(items[selected_idx], selected_idx)
  end
end

describe("setup", function()
  it("select_keymap works", function()
    before_each()
    override_select("a")
    plugin.select_keymap()

    assert.are.equals("a", vim.g._result_item.label)
    assert.are.equals("index.txt:373", vim.g._result_item.metadata.debug[1]:match("index.txt:373"))
    assert.are.equals(1, vim.g._result_idx)
  end)

  it("select_keymap with motion works", function()
    before_each()
    override_select("c{motion}")
    plugin.select_keymap()

    assert.are.equals("cgd", vim.g._result_item.label)
    assert.are.equals("index.txt:375", vim.g._result_item.metadata.debug[1]:match("index.txt:375"))
    assert.are.equals(4, vim.g._result_idx)
  end)

  it("select_keymap for override works", function()
    before_each()
    override_select("a")
    vim.keymap.set("n", "a", "ciwapple<esc>")
    plugin.select_keymap()

    assert.are.equals("a", vim.g._result_item.label)
    assert.are.equals("keymap-menu_spec.lua", vim.g._result_item.metadata.debug[1]:match("keymap%-menu_spec%.lua"))
    assert.are.equals(1, vim.g._result_idx)
  end)

  it("select_keymap for function based override works", function()
    local function test_rhs() end

    before_each()
    override_select("a")
    vim.keymap.set({ "n", "x", "o" }, "a", test_rhs)
    plugin.select_keymap()

    assert.are.equals("a", vim.g._result_item.label)
    assert.are.equals("keymap-menu_spec.lua", vim.g._result_item.metadata.debug[1]:match("keymap%-menu_spec%.lua"))
    assert.are.equals(1, vim.g._result_idx)
  end)

  it("remap delete works", function()
    before_each()
    override_select("<del>")
    vim.keymap.set("n", "<Del>", '"_x')
    plugin.select_keymap()

    assert.are.equals("<del>", vim.g._result_item.label)
    assert.are.equals("keymap-menu_spec.lua", vim.g._result_item.metadata.debug[1]:match("keymap%-menu_spec%.lua"))
    assert.are.equals(selected_idx, vim.g._result_idx)
  end)
end)
