local M = {}

local assert_direction = function(direction)
  if
    direction ~= nil
    and direction ~= "forward"
    and direction ~= "backward"
  then
    error(
      'direction must be one of these "forward"|"backward"|nil, but it is: '
        .. tostring(direction)
    )
  end
end

local assert_pattern = function(pattern)
  if type(pattern) ~= "string" then
    error("pattern must be a string, but it is: " .. tostring(type(pattern)))
  end
end

local assert_offset = function(offset)
  if
    offset ~= nil
    and offset ~= "pre"
    and offset ~= "start"
    and offset ~= "end"
    and offset ~= "post"
  then
    error(
      'offset must be one of these "pre"|"start"|"end"|"post"|nil, but it is: '
        .. tostring(offset)
    )
  end
end

---Options that a user gives
---@class RH_UserHopOptions
---@field direction "forward"|"backward"|nil direction to search a given pattern
---@field offset "pre"|"start"|"end"|"post"|nil offset to cursor to place
---@field pattern string pattern to search

---Asserts all the fields of the options
---@param options RH_UserHopOptions
M.assert = function(options)
  assert_direction(options.direction)
  assert_pattern(options.pattern)
  assert_offset(options.offset)
end

---Fills empty fields with default values
---@param options RH_UserHopOptions
M.fill_default = function(options)
  if options.direction == nil then
    options.direction = "forward"
  end

  if options.offset == nil then
    options.offset = "start"
  end
end

return M
