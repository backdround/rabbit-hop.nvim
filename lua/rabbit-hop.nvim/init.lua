local jump = require("rabbit-hop.jump")
local new_jump_options_manager = require("rabbit-hop.jump-options-manager").new

local M = {}

M._reset_state = function()
  M._jump_options_manager = new_jump_options_manager()
end
M._reset_state()

---@param opts RH_UserJumpOptions
M.jump = function(opts)
  local jump_options = M._jump_options_manager.get_from_user_options(opts)
  jump(jump_options)
end

return M
