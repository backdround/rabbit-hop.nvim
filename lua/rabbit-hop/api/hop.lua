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
---@return RH_Position|nil
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

  local insert_adjust = function(p)
    if opts.insert_mode_target_side == "right" then
      p:move(1)
    end
  end

  local apply_offset = function(match)
    if opts.offset == "start" then
      local p = match:start_position()
      insert_adjust(p)
      return p
    elseif opts.offset == "end" then
      local p = match:end_position()
      insert_adjust(p)
      return p
    end

    local shift_right = (opts.direction == "forward" and opts.offset == "post")
      or (opts.direction == "backward" and opts.offset == "pre")

    if shift_right then
      local p = match:end_position()
      p:move(1)
      insert_adjust(p)
      return p
    else
      local p = match:start_position()
      p:move(-1)
      insert_adjust(p)
      return p
    end
  end

  local current_position = position.from_cursor(true)
  local match_is_suitable = function(match)
    local potential_target_position = apply_offset(match)
    if opts.direction == "forward" then
      return potential_target_position > current_position
    else
      return potential_target_position < current_position
    end
  end

  local count = opts.count
  while true do
    if match_is_suitable(iterator) then
      count = count - 1
    end

    if count == 0 then
      return apply_offset(iterator)
    end

    local performed = false
    if opts.direction == "forward" then
      performed = iterator:next()
    else
      performed = iterator:previous()
    end

    if not performed then
      return apply_offset(iterator)
    end
  end
end

---Options that describe the hop behaviour.
---@class RH_HopOptions
---@field direction "forward"|"backward" direction to search a given pattern
---@field offset "pre"|"start"|"end"|"post" offset of the cursor to the place
---@field pattern string pattern to search
---@field insert_mode_target_side "left"|"right" side to place the cursor in insert mode
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
