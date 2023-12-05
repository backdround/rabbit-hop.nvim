local hop = require("rabbit-hop.hop")
local new_hop_options_manager = require("rabbit-hop.hop-options-manager").new

local M = {}

M._reset_state = function()
  M._hop_options_manager = new_hop_options_manager()
end
M._reset_state()

---@param opts RH_UserHopOptions
M.hop = function(opts)
  local hop_options = M._hop_options_manager.get_from_user_options(opts)
  hop(hop_options)
end

return M
