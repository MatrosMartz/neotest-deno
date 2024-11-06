local M = {}

---@return table<string, string>
M.get_args = function()
	return {}
end

---@return table<string, string>?
M.get_allow = function()
	return nil
end

---@return table<string, string>
M.get_additional_root_files = function()
	return {}
end

---@return table<string, string>
M.get_additional_filter_dirs = function()
	return {}
end

---@return string
M.get_dap_adapter = function()
	return "pwa-node"
end

return M
