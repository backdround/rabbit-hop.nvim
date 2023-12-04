local user_options_utils = require("rabbit-hop.user-options-utils")
local utils = require("rabbit-hop.utils")

---@return RH_JumpOptionsManager
local new = function()
  ---@class RH_JumpOptionsManager
  local manager = {
    _dot_repetition_cache = {},
  }

  ---@param user_options RH_UserJumpOptions
  ---@return RH_JumpOptions
  manager.get_from_user_options = function(user_options)
    user_options = vim.deepcopy(user_options or {})

    user_options_utils.assert(user_options)
    user_options_utils.fill_default(user_options)

    local jump_options = {
      direction = user_options.direction,
      offset = user_options.offset,
    }

    -- Get pattern
    if utils.is_vim_repeat() then
      jump_options.pattern = manager._dot_repetition_cache.pattern
    elseif user_options.pattern ~= nil then
      jump_options.pattern = user_options.pattern
    end

    -- Get count
    if vim.v.count ~= 0 then
      jump_options.count = vim.v.count
    elseif utils.is_vim_repeat() then
      jump_options.count = manager._dot_repetition_cache.count
    else
      jump_options.count = 1
    end

    -- Save caches
    manager._dot_repetition_cache = jump_options

    return jump_options
  end

  return manager
end

return {
  new = new
}
