local hop = require(RH_ROOT .. ".api.hop")
local new_hop_option_manager = require(RH_ROOT .. ".api.hop-option-manager").new

local M = {}

M.reset_state = function()
  M._hop_option_manager = new_hop_option_manager()
end
M.reset_state()

---@param user_options RH_UserHopOptions
M.hop = function(user_options)
  local hop_options = M._hop_option_manager.get_from_user_options(user_options)
  hop(hop_options)
end

---@return RH_HopOptions|nil
M.get_last_hop_options = function()
  return M._hop_option_manager.get_from_user_options()
end

return M
