local h = require("tests.helpers")

require("tests.custom-asserts").register()

local pattern = "\\M<a>"
describe("near-pattern-hop", function()
  describe("forward", function()
    it("pre from a pattern", function()
      h.get_preset("<a> <a>", { 1, 0 })()
      h.hop("forward", "pre", pattern)
      assert.cursor_at(1, 3)
    end)

    it("pre from a pre pattern", function()
      h.get_preset("|<a> <a>", { 1, 0 })()
      h.hop("forward", "pre", pattern)
      assert.cursor_at(1, 4)
    end)

    it("start from a pattern", function()
      h.get_preset("<a> <a>", { 1, 0 })()
      h.hop("forward", "start", pattern)
      assert.cursor_at(1, 4)
    end)

    it("end from a pattern", function()
      h.get_preset("aaa", { 1, 0 })()
      h.hop("forward", "end", "a")
      assert.cursor_at(1, 1)
    end)

    it("post from a pattern", function()
      h.get_preset("aaa", { 1, 0 })()
      h.hop("forward", "post", "a")
      assert.cursor_at(1, 1)
    end)
  end)

  describe("backward", function()
    it("pre from a pattern", function()
      h.get_preset("<a> <a>", { 1, 6 })()
      h.hop("backward", "pre", pattern)
      assert.cursor_at(1, 3)
    end)

    it("pre from pre a pattern", function()
      h.get_preset("<a> <a>|", { 1, 7 })()
      h.hop("backward", "pre", pattern)
      assert.cursor_at(1, 3)
    end)

    it("end from a pattern", function()
      h.get_preset("<a> <a>", { 1, 6 })()
      h.hop("backward", "end", pattern)
      assert.cursor_at(1, 2)
    end)

    it("start from a pattern", function()
      h.get_preset("aaa", { 1, 2 })()
      h.hop("backward", "start", "a")
      assert.cursor_at(1, 1)
    end)

    it("post from a pattern", function()
      h.get_preset("aaa", { 1, 2 })()
      h.hop("backward", "post", "a")
      assert.cursor_at(1, 1)
    end)
  end)
end)
