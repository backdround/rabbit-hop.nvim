local M = {}

M.reset_state = function()
  M._hop_options_manager = require("rabbit-hop.api.hop-options-manager").new()
end
M.reset_state()

---@param user_options RH_UserHopOptions
M.hop = function(user_options)
  local hop_options = M._hop_options_manager.get_from_user_options(user_options)
  require("rabbit-hop.api.hop")(hop_options)
end

---@return RH_HopOptions|nil
M.get_last_hop_options = function()
  return M._hop_options_manager.get_from_user_options()
end

return M
