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
---@return string | nil
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

---@param tree neotest.Tree
---@return {regex: string, key: string}[]
local get_parameterizeds = function(tree)
	local parameterieds = {}

	for _, pos in tree:iter() do
		---@cast pos {is_parameterized: boolean, id: string, name: string}
		if pos.is_parameterized then
			table.insert(parameterieds, {
				regex = pos.name:gsub("%${[^{}]+}", ".+"),
				key = pos.id,
			})
		end
	end
	return parameterieds
end

---@param tree neotest.Tree
---@return fun(test_suit: string, test_name: string): string
M.create_get_result_key = function(tree)
	local parameterieds = get_parameterizeds(tree)

	return function(test_suite, test_name)
		local a = test_suite .. test_name
		for _, parameteried in ipairs(parameterieds) do
			local match = test_name:find(parameteried.regex)
			if match then
				return parameteried.key
			end
		end
		return a
	end
end

return M
