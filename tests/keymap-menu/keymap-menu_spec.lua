describe("setup", function()
  it("search_normal_keys works", function()
    vim.ui.select = function(items, opts, on_choice)
      on_choice(items[1], 1)
    end

    local plugin = require("keymap-menu")
    plugin.setup()
    plugin.search_normal_keymaps(function(item, idx)
      vim.g._result_item = item
      vim.g._result_idx = idx
    end)

    assert.are.equals("a", vim.g._result_item.label)
    assert.are.equals("index.txt:373", vim.g._result_item.metadata.debug[1]:match("index.txt:373"))
    assert.are.equals(1, vim.g._result_idx)
  end)

  it("search_normal_keys with motion works", function()
    vim.ui.select = function(items, opts, on_choice)
      on_choice(items[4], 1)
    end

    local plugin = require("keymap-menu")
    plugin.setup()
    plugin.search_normal_keymaps(function(item, idx)
      vim.g._result_item = item
      vim.g._result_idx = idx
    end)

    assert.are.equals("ciw", vim.g._result_item.label)
    assert.are.equals("index.txt:375", vim.g._result_item.metadata.debug[1]:match("index.txt:375"))
    assert.are.equals(1, vim.g._result_idx)
  end)

  it("search_normal_keys for override works", function()
    vim.ui.select = function(items, opts, on_choice)
      on_choice(items[1], 1)
    end

    local plugin = require("keymap-menu")
    plugin.setup()
    vim.keymap.set("n", "a", "ciwapple<esc>")
    plugin.search_normal_keymaps(function(item, idx)
      vim.g._result_item = item
      vim.g._result_idx = idx
    end)

    assert.are.equals("a", vim.g._result_item.label)
    assert.are.equals("keymap-menu_spec.lua", vim.g._result_item.metadata.debug[1]:match("keymap%-menu_spec%.lua"))
    assert.are.equals(1, vim.g._result_idx)
  end)

  it("search_normal_keys for override with function works", function()
    vim.ui.select = function(items, opts, on_choice)
      on_choice(items[1], 1)
    end

    local function test_rhs() end

    local plugin = require("keymap-menu")
    plugin.setup()
    vim.keymap.set({ "n", "x", "o" }, "a", test_rhs)
    plugin.search_normal_keymaps(function(item, idx)
      vim.g._result_item = item
      vim.g._result_idx = idx
    end)

    assert.are.equals("a", vim.g._result_item.label)
    assert.are.equals("keymap-menu_spec.lua", vim.g._result_item.metadata.debug[1]:match("keymap%-menu_spec%.lua"))
    assert.are.equals(1, vim.g._result_idx)
  end)

  it("remap delete works", function()
    local selected_idx = 1

    vim.ui.select = function(items, opts, on_choice)
      for idx, item in ipairs(items) do
        if item.metadata.lhs == "<del>" then
          selected_idx = idx
          break
        end
      end

      on_choice(items[selected_idx], selected_idx)
    end

    local plugin = require("keymap-menu")
    plugin.setup()
    vim.keymap.set("n", "<Del>", '"_x')
    plugin.search_normal_keymaps(function(item, idx)
      vim.g._result_item = item
      vim.g._result_idx = idx
    end)

    assert.are.equals("<del>", vim.g._result_item.label)
    assert.are.equals("keymap-menu_spec.lua", vim.g._result_item.metadata.debug[1]:match("keymap%-menu_spec%.lua"))
    assert.are.equals(selected_idx, vim.g._result_idx)
  end)
end)
