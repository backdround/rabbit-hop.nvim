local api_helpers = require("tests.api-helpers")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("corner cases", function()
  describe("hop from the middle of the pattern", function()
    before_each(h.get_preset("aa aa aaaaa aa aa", { 1, 8 }))

    it("forward to the end", function()
      api_helpers.hop("forward", "end", "\\va+")
      assert.cursor_at(1, 10)
    end)

    it("forward to the start", function()
      api_helpers.hop("forward", "start", "\\va+")
      assert.cursor_at(1, 12)
    end)

    it("backward to the end", function()
      api_helpers.hop("backward", "end", "\\va+")
      assert.cursor_at(1, 4)
    end)

    it("backward to the start", function()
      api_helpers.hop("backward", "start", "\\va+")
      assert.cursor_at(1, 6)
    end)
  end)

  describe("hop to the start or end of a line", function()
    before_each(h.get_preset([[
      multi
       | line
      text
    ]], { 2, 1 }))

    it("the start of the start of a line", function()
      api_helpers.hop("backward", "start", "\\v^")
      assert.cursor_at(2, 0)
    end)

    it("the end of the start of a line", function()
      api_helpers.hop("backward", "end", "\\v^")
      assert.cursor_at(2, 0)
    end)

    it("the start of the end of a line", function()
      api_helpers.hop("forward", "start", "\\v$")
      assert.cursor_at(2, 6)
    end)

    it("the end of the end of a line", function()
      api_helpers.hop("forward", "end", "\\v$")
      assert.cursor_at(2, 6)
    end)
  end)
end)
