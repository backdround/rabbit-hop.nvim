local lazy_rabbit_hop = function(options)
  local rabbit_hop = require("rabbit-hop.api").hop
  return rabbit_hop(options)
end

local M = {}

---@class RH_PluginOptions :RH_ApiHopOptions

---@param plugin_options RH_PluginOptions
---@return boolean The hop has been performed.
M.hop = function(plugin_options)
  ---@type RH_ApiHopOptions
  local api_options = {
    pattern = plugin_options.pattern,
    direction = plugin_options.direction,
    match_position = plugin_options.match_position,
    offset = plugin_options.offset,
    insert_mode_target_side = plugin_options.insert_mode_target_side,
    accept_policy = plugin_options.accept_policy,
    fold_policy = plugin_options.fold_policy,
    count = vim.v.count1
  }

  return lazy_rabbit_hop(api_options)
end

return M
