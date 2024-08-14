local async = require("neotest.async")
local Path = require("plenary.path")
local sep = Path.path.sep

local M = {}

M.is_callable = function(obj)
	return type(obj) == "function" or (type(obj) == "table" and obj.__call)
end

-- Hacky workaround to get the name of the output file
M.get_results_file = function()
	local tmp_dir, idx = string.match(async.fn.tempname(), "(.*)(%d+)$")
	return tmp_dir .. (tonumber(idx) + 1)
end

-- Extract test name from output line. Add quotes if necessary
---@return string
M.get_test_name = function(output_line)
	local test_name = string.match(output_line, "^%s*(.*) %.%.%..*$")
	-- if string.match(test_name, " ") then
	-- 	test_name = '"' .. test_name .. '"'
	-- end
	return test_name
end

M.path_join = function(...)
	return table.concat({ ... }, sep)
end

---@param str string
---@param ending string
M.ends_with = function(str, ending)
	return str:sub(-#ending) == ending
end

return M
