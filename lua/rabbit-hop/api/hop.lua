local pattern_iterator = require(({ ... })[1]:gsub("[^.]+%.[^.]+$", "") .. "pattern-iterator")
local position = require(({ ... })[1]:gsub("[^.]+%.[^.]+$", "") .. "pattern-iterator.position")

---@return "operator-pending"|"visual"|"normal"|"insert"
local mode = function()
  local m = tostring(vim.fn.mode(true))

  if m:find("o") then
    return "operator-pending"
  elseif m:find("[vV]") then
    return "visual"
  elseif m:find("i") then
    return "insert"
  else
    return "normal"
  end
end

---@param opts RH_HopOptions
---@param n_is_pointable boolean position can point to a "\n"
---@return PI_Position|nil
local function search_target_position(opts, n_is_pointable)
  local iterator_opts = { n_is_pointable = n_is_pointable }

  local iterator = pattern_iterator.new_around(opts.pattern, iterator_opts)

  if iterator == nil then
    if opts.direction == "forward" then
      iterator = pattern_iterator.new_forward(opts.pattern, iterator_opts)
    else
      iterator = pattern_iterator.new_backward(opts.pattern, iterator_opts)
    end
  end

  if iterator == nil then
    return nil
  end

  local apply_offset = function(match)
    local p = nil
    if opts.match_position == "start" then
      p = match:start_position()
    else
      p = match:end_position()
    end

    p:move(opts.offset)

    if mode() == "insert" and opts.insert_mode_target_side == "right" then
      p:move(1)
    end

    return p
  end

  local final_position = nil
  local count = opts.count
  while true do
    local potential_target_position = apply_offset(iterator)

    local suitable = false
    if opts.direction == "forward" then
      suitable = potential_target_position:after_cursor()
    else
      suitable = potential_target_position:before_cursor()
    end

    if suitable then
      count = count - 1
      final_position = potential_target_position
    end

    if count == 0 then
      return final_position
    end

    local performed = false
    if opts.direction == "forward" then
      performed = iterator:next()
    else
      performed = iterator:previous()
    end

    if not performed then
      return final_position
    end
  end
end

---Options that describe the hop behaviour.
---@class RH_HopOptions
---@field pattern string
---@field direction "forward"|"backward"
---@field match_position "start"|"end" Indicates which end of the match to use.
---@field offset number Advances final position relatively match_position.
---@field insert_mode_target_side "left"|"right" side to place the cursor in insert mode.
---@field count number count of hops to perform

---Performs a hop to a given pattern
---@param opts RH_HopOptions
local perform = function(opts)
  local n_is_pointable = mode() ~= "normal"
  local target_position = search_target_position(opts, n_is_pointable)

  if not target_position then
    return
  end

  if
    mode() == "visual"
    and vim.go.selection == "exclusive"
    and opts.direction == "forward"
  then
    target_position:move(1)
  end

  if mode() ~= "operator-pending" then
    target_position:set_cursor()
    return
  end

  local start_position = position.from_cursor(n_is_pointable)
  if opts.direction == "backward" then
    start_position:move(-1)
  end

  start_position:perform_operator_to(target_position)
end

return perform
