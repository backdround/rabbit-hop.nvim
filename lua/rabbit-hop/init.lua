local M = {}

---@param user_options RH_UserHopOptions
M.hop = function(user_options)
  if M._hop_options_manager == nil then
    M._hop_options_manager = require("rabbit-hop.hop-options-manager").new()
  end

  local hop_options = M._hop_options_manager.get_from_user_options(user_options)
  require("rabbit-hop.hop")(hop_options)
end

return M
