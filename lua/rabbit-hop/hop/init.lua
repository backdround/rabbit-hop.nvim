local utils = require("rabbit-hop.utils")
local position = require("rabbit-hop.hop.position")
local search_pattern = require("rabbit-hop.hop/search-pattern")

---@param opts RH_HopOptions
---@param n_is_pointable boolean position can point to a "\n"
---@return RH_Position|nil
local function search_target_position(opts, n_is_pointable)
  local target_pattern = search_pattern(opts, n_is_pointable)

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
