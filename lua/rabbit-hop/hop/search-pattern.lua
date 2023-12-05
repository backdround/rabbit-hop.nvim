local position = require("rabbit-hop.hop.position")

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
local function search_pattern(opts, n_is_pointable)
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

return search_pattern
