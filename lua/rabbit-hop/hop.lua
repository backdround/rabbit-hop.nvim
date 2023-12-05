
local utils = require("rabbit-hop.utils")
local position = require("rabbit-hop.position")

---@param direction "forward"|"backward"
---@param offset "pre"|"start"|"end"|"post"
---@param n_is_pointable boolean
---@return RH_IgnoredPatternPositions
local function new_ignored_pattern_positions(direction, offset, n_is_pointable)
  ---Represents pattern positions that must be ignored during pattern search
  ---@class RH_IgnoredPatternPositions
  local ipp = {
    _start_ignored_positions = {},
    _end_ignored_positions = {},
  }

  -- Initialize start ignored positions
  if offset == "start" or offset == "pre" then
    local current_position = position.from_cursor(n_is_pointable)
    table.insert(ipp._start_ignored_positions, current_position)
  end

  if offset == "pre" and direction == "forward" then
    local current_position = position.from_cursor(n_is_pointable)
    current_position.forward_once()
    table.insert(ipp._start_ignored_positions, current_position)
  elseif offset == "pre" and direction == "backward" then
    local current_position = position.from_cursor(n_is_pointable)
    current_position.backward_once()
    table.insert(ipp._start_ignored_positions, current_position)
  end

  -- Initialize end ignored positions
  if offset == "end" then
    local current_position = position.from_cursor(n_is_pointable)
    table.insert(ipp._end_ignored_positions, current_position)
  end

  ---Tests if a given pattern position must be ignored.
  ---@param pattern_position RH_PatternPosition
  ---@return boolean
  ipp.is_ignored = function(pattern_position)
    for _, start_ignored_position in ipairs(ipp._start_ignored_positions) do
      if pattern_position.start_position == start_ignored_position then
        return true
      end
    end

    for _, end_ignored_position in ipairs(ipp._end_ignored_positions) do
      if pattern_position.end_position == end_ignored_position then
        return true
      end
    end

    return false
  end

  return ipp
end

---@class RH_PatternPosition
---@field start_position RH_Position
---@field end_position RH_Position

---@param opts RH_HopOptions
---@param n_is_pointable boolean position can point to a "\n"
---@return RH_PatternPosition|nil
local function search_target_pattern(opts, n_is_pointable)
  local flags = "cnW"
  if opts.direction == "backward" then
    flags = flags .. "b"
  end

  local ignored_pattern_positions =
    new_ignored_pattern_positions(opts.direction, opts.offset, n_is_pointable)

  local found_pattern = nil
  local count = opts.count
  local search_callback = function()
    -- Get potential found pattern
    local potential_found_pattern = {
      start_position = position.from_cursor(n_is_pointable)
    }

    local find_end_position = function()
      potential_found_pattern.end_position =
        position.from_cursor(n_is_pointable)
      return 0
    end
    vim.fn.searchpos(opts.pattern, "nWce", nil, nil, find_end_position)

    -- Check the potential position
    if ignored_pattern_positions.is_ignored(potential_found_pattern) then
      return 1
    end

    -- Save pattern
    found_pattern = potential_found_pattern

    -- Count down
    count = count - 1
    return count
  end

  vim.fn.searchpos(opts.pattern, flags, nil, nil, search_callback)

  return found_pattern
end

---@param opts RH_HopOptions
---@param n_is_pointable boolean position can point to a "\n"
---@return RH_Position|nil
local function search_target_position(opts, n_is_pointable)
  local target_pattern = search_target_pattern(opts, n_is_pointable)

  if not target_pattern then
    return nil
  end

  local pattern_start = target_pattern.start_position
  local pattern_end = target_pattern.end_position

  if opts.direction == "forward" then
    if opts.offset == "pre" then
      pattern_start.backward_once()
      return pattern_start
    elseif opts.offset == "start" then
      return pattern_start
    elseif opts.offset == "end" then
      return pattern_end
    elseif opts.offset == "post" then
      pattern_end.forward_once()
      return pattern_end
    end
  end

  if opts.direction == "backward" then
    if opts.offset == "pre" then
      pattern_end.forward_once()
      return pattern_end
    elseif opts.offset == "end" then
      return pattern_end
    elseif opts.offset == "start" then
      return pattern_start
    elseif opts.offset == "post" then
      pattern_start.backward_once()
      return pattern_start
    end
  end
end

---Options that describe the hop behaviour.
---@class RH_HopOptions
---@field direction "forward"|"backward" direction to search a given pattern
---@field offset "pre"|"start"|"end"|"post" offset of the cursor to the place
---@field pattern string pattern to search
---@field count number count of hops to perform

---Performs a hop to a given pattern
---@param opts RH_HopOptions
local perform = function(opts)
  local n_is_pointable = utils.mode() ~= "normal"
  local target_position = search_target_position(opts, n_is_pointable)

  if not target_position then
    return
  end

  if
    utils.mode() == "visual"
    and vim.go.selection == "exclusive"
    and opts.direction == "forward"
  then
    target_position.forward_once()
  end

  if utils.mode() ~= "operator-pending" then
    target_position.set_cursor()
    return
  end

  local start_position = position.from_cursor(n_is_pointable)
  if opts.direction == "backward" then
    start_position.backward_once()
  end

  start_position.select_region_to(target_position)
end

return perform
