local rh = require("rabbit-hop")
local h = require("tests.helpers")

require("tests.custom-asserts").register()


describe("user-options", function()
  before_each(h.get_preset([[
    aa bb aa bb aa bb
  ]], { 1, 0 }))

  it('"direction" should be "forward" by default', function()
    h.perform_through_keymap(rh.hop, true, {
      direction = nil,
      offset = "start",
      pattern = "aa"
    })
    assert.cursor_at(1, 6)
  end)

  it('"offset" should be "start" by default', function()
    h.perform_through_keymap(rh.hop, true, {
      direction = "forward",
      offset = nil,
      pattern = "aa"
    })
    assert.cursor_at(1, 6)
  end)

  it('"insert_mode_target_side" should be "left" by default', function()
    h.trigger_insert()
    h.perform_through_keymap(rh.hop, true, {
      direction = "forward",
      offset = "start",
      insert_mode_target_side = "left",
      pattern = "bb"
    })
    assert.cursor_at(1, 2)
  end)

  it('"insert_mode_target_side" should shift position if "right"', function()
    h.trigger_insert()
    h.perform_through_keymap(rh.hop, true, {
      direction = "forward",
      offset = "start",
      insert_mode_target_side = "right",
      pattern = "bb",
    })
    assert.cursor_at(1, 3)
  end)
end)
