local lib = require("neotest.lib")
local utils = require("neotest-deno.utils")
local config = require("neotest-deno.config")

---@class neotest.Adapter
---@field name string
local DenoNeotestAdapter = { name = "neotest-deno" }

---Escape Test Patterns
---@param s string
---@return string
local escape_test_pattern = function(s)
	return (
		s:gsub("%(", "%\\(")
			:gsub("%)", "%\\)")
			:gsub("%]", "%\\]")
			:gsub("%[", "%\\[")
			:gsub("%}", "%\\}")
			:gsub("%{", "%\\{")
			:gsub("%.", "%\\.")
			:gsub("%+", "%\\+")
			:gsub("%*", "%\\*")
			:gsub("%-", "%\\-")
			:gsub("%^", "%\\^")
			:gsub("%$", "%\\$")
			:gsub("%?", "%\\?")
			:gsub("%'", "%\\'")
			:gsub("%/", "%\\/")
			:gsub("%\\", "%\\\\")
	)
end

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function DenoNeotestAdapter.root(dir)
	local result = nil
	local root_files =
		vim.list_extend(config.get_additional_root_files(), { "deno.json", "deno.jsonc", "import_map.json" })

	for _, root_file in ipairs(root_files) do
		result = lib.files.match_root_pattern(root_file)(dir)
		if result then
			break
		end
	end

	return result
end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---!param rel_path string Path to directory, relative to root
---!param root string Root directory of project
function DenoNeotestAdapter.filter_dir(name)
	local filter_dirs = vim.list_extend(config.get_additional_filter_dirs(), { "node_modules" })

	for _, filter_dir in ipairs(filter_dirs) do
		if name == filter_dir then
			return false
		end
	end

	return true
end

---@async
---@param file_path string
---@return boolean
function DenoNeotestAdapter.is_test_file(file_path)
	-- See https://deno.land/manual@v1.27.2/basics/testing#running-tests
	local valid_exts = {
		js = true,
		ts = true,
		tsx = true,
		mts = true,
		mjs = true,
		jsx = true,
		cjs = true,
		cts = true,
	}

	-- Get filename
	local file_name = string.match(file_path, ".-([^\\/]-%.?[^%.\\/]*)$")

	-- filename match _ . or test.
	local ext = string.match(file_name, "[_%.]test%.(%w+)$") -- Filename ends in _test.<ext> or .test.<ext>
		or string.match(file_name, "^test%.(%w+)$") -- Filename is test.<ext>
		or nil

	if ext and valid_exts[ext] then
		return true
	end

	return false
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function DenoNeotestAdapter.discover_positions(file_path)
	-- TODO: discover flat describe

	local deno_test = [[
  ; -- t.step 1 --
  ((call_expression
    function: (member_expression property: (property_identifier) @test_step (#eq? @test_step "step"))
    arguments: (arguments (_
      parameters: (formal_parameters . (required_parameter pattern: (identifier) @test_id))
      body: (statement_block
        [
          (expression_statement (await_expression (call_expression
            function: [
              (member_expression
                object: (identifier) @test_obj (#eq? @test_obj @test_id)
                property: (property_identifier) @test_step (#eq? @test_step "step")
              )
              (member_expression
                object:(member_expression
                  object: (identifier) @test_obj (#eq? @test_obj @test_id)
                  property: (property_identifier) @test_step (#eq? @test_step "step")
                )
                property: (property_identifier) @test_only (#eq? @test_only "only")
              )
            ]
            arguments: [
              (arguments . (string (string_fragment) @test.name) . (object)? . [(arrow_function) (function_expression)])
              (arguments . (object)? . (function_expression name: (identifier) @test.name))
              (arguments . (object (pair
                key: (property_identifier) @key (#eq? @key "name")
                value: (string (string_fragment) @test.name)
              )))
            ]
          )))
          (lexical_declaration (variable_declarator
            value: (await_expression(call_expression
              function: (member_expression
                object: (identifier) @test_obj (#eq? @test_obj @test_id)
                property: (property_identifier) @test_step (#eq? @test_step "step")
              )
              arguments: [
                (arguments . (string (string_fragment) @test.name) . (object)? . [(arrow_function) (function_expression)])
                (arguments . (object)? . (function_expression name: (identifier) @test.name))
                (arguments . (object (pair
                  key: (property_identifier) @key (#eq? @key "name")
                  value: (string (string_fragment) @test.name)
                )))
              ]
            ))
          ))
        ] @test.definition
      )
    ) .)
  ))

  ; -- t.step 2 --
  ((call_expression
    function: (member_expression property: (property_identifier) @test_step (#eq? @test_step "step"))
    arguments: (arguments (object (pair
      key: (property_identifier) @step_key (#eq? @step_key "fn")
      value: (_
        parameters: (formal_parameters . (required_parameter pattern: (identifier) @test_id))
        body: (statement_block
          [
            (expression_statement (await_expression (call_expression
              function: [
                (member_expression
                  object: (identifier) @test_obj (#eq? @test_obj @test_id)
                  property: (property_identifier) @test_step (#eq? @test_step "step")
                )
                (member_expression
                  object:(member_expression
                    object: (identifier) @test_obj (#eq? @test_obj @test_id)
                    property: (property_identifier) @test_step (#eq? @test_step "step")
                  )
                  property: (property_identifier) @test_only (#eq? @test_only "only")
                )
              ]
              arguments: [
                (arguments . (string (string_fragment) @test.name) . (object)? . [(arrow_function) (function_expression)])
                (arguments . (object)? . (function_expression name: (identifier) @test.name))
                (arguments . (object (pair
                  key: (property_identifier) @key (#eq? @key "name")
                  value: (string (string_fragment) @test.name)
                )))
              ]
            )))
            (lexical_declaration (variable_declarator
              value: (await_expression(call_expression
                function: (member_expression
                  object: (identifier) @test_obj (#eq? @test_obj @test_id)
                  property: (property_identifier) @test_step (#eq? @test_step "step")
                )
                arguments: [
                  (arguments . (string (string_fragment) @test.name) . (object)? . [(arrow_function) (function_expression)])
                  (arguments . (object)? . (function_expression name: (identifier) @test.name))
                  (arguments . (object (pair
                    key: (property_identifier) @key (#eq? @key "name")
                    value: (string (string_fragment) @test.name)
                  )))
                ]
              ))
            ))
          ] @test.definition
        )
      )
    )) .)
  ))

  ; -- Deno.test nested --
  ((call_expression
    function: (member_expression) @deno_test (#any-of? @deno_test "Deno.test" "Deno.test.only")
    arguments: (arguments (_
      parameters: (formal_parameters . (required_parameter pattern: (identifier) @test_id))
      body: (statement_block
        [
          (expression_statement (await_expression (call_expression
            function: [
              (member_expression
                object: (identifier) @test_obj (#eq? @test_obj @test_id)
                property: (property_identifier) @test_step (#eq? @test_step "step")
              )
              (member_expression
                object:(member_expression
                  object: (identifier) @test_obj (#eq? @test_obj @test_id)
                  property: (property_identifier) @test_step (#eq? @test_step "step")
                )
                property: (property_identifier) @test_only (#eq? @test_only "only")
              )
            ]
            arguments: [
              (arguments . (string (string_fragment) @test.name) . (object)? . [(arrow_function) (function_expression)])
              (arguments . (object)? . (function_expression name: (identifier) @test.name))
              (arguments . (object (pair
                key: (property_identifier) @key (#eq? @key "name")
                value: (string (string_fragment) @test.name)
              )))
            ]
          )))
          (lexical_declaration (variable_declarator
            value: (await_expression(call_expression
              function: (member_expression
                object: (identifier) @test_obj (#eq? @test_obj @test_id)
                property: (property_identifier) @test_step (#eq? @test_step "step")
              )
              arguments: [
                (arguments . (string (string_fragment) @test.name) . (object)? . [(arrow_function) (function_expression)])
                (arguments . (object)? . (function_expression name: (identifier) @test.name))
                (arguments . (object (pair
                  key: (property_identifier) @key (#eq? @key "name")
                  value: (string (string_fragment) @test.name)
                )))
              ]
            ))
          ))
        ] @test.definition
      )
    ) .)
  ))

  ; -- Deno.test flat --
  ((call_expression
    function: (member_expression) @deno_test (#any-of? @deno_test "Deno.test")
    arguments: [
      ; Matches: `Deno.test("name", () => {})`
      ; Matches: `Deno.test("name", { opts }, () => {})`
      (arguments . (string (string_fragment) @test.name) . (object)? . [(arrow_function) (function_expression)] .)
      ; Matches: `Deno.test(function name() {})`
      ; Matches: `Deno.test({ opts }, function name() {})`
      (arguments . (object)? . (function_expression name: (identifier) @test.name) .)
      ; Matches `Deno.test({name: "name", fn: () => {} })`
      (arguments . (object (pair
        key: (property_identifier) @key (#eq? @key "name")
        value: (string (string_fragment) @test.name))
      ))
    ]
  )) @test.definition
  ]]

	local bdd = [[
  ; BDD describe - nested
  (call_expression
    function: [
      ((_) @func_name (#any-of? @func_name "describe.only" "describe.ignore" "describe"))
    ]
    arguments: [
      (arguments . ((string (string_fragment) @namespace.name ) . (object)? . [(arrow_function) (function_expression)]))
      (arguments . (object)? . (function_expression name: (identifier) @namespace.name) .)
      (arguments . (object (pair
        key: (property_identifier) @key (#eq? @key "name")
        value: (string (string_fragment) @namespace.name)
      )).)
    ]
  ) @namespace.definition

  ; -- BDD it/test --
  ((call_expression
    function:
    	((_) @func_name (#any-of? @func_name "it" "test" "it.only" "it.ignore" "test.only" "test.ignore"))
    arguments: [
      ; Matches: `it("name", () => {})`
      ; Matches: `it("name", { opts }, () => {})`
      (arguments . (identifier)? . (string (string_fragment) @test.name) . (object)? . [(arrow_function) (function_expression)] .)
      ; Matches: `it(function name() {})`
      ; Matches: `Deno.test({ opts }, function name() {})`
      (arguments (object)? . (function_expression name: (identifier) @test.name) .)
      ; Matches `it({name: "name", fn: () => {} })`
      (arguments . (object (pair
        key: (property_identifier) @key (#eq? @key "name")
        value: (string (string_fragment) @test.name))
      ))
    ]
  )) @test.definition
  ]]

	local query = deno_test .. bdd

	local position_tree = lib.treesitter.parse_positions(file_path, query, { nested_tests = true })

	return position_tree
end

---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
function DenoNeotestAdapter.build_spec(args)
	local results_path = utils.get_results_file()

	if not args.tree then
		return
	end

	local position = args.tree:data()
	local strategy = {}

	local cwd = assert(DenoNeotestAdapter.root(position.path), "could not locate root directory of " .. position.path)

	local command = vim.iter({
		"deno",
		"test",
		position.path,
		"--no-prompt",
		vim.list_extend(config.get_args(), args.extra_args or {}),
		config.get_allow() or "--allow-all",
	})
		:flatten(math.huge)
		:totable()

	if position.type == "test" or position.type == "namespace" then
		local first_separator = position.id:find("::") + 2
		local test_name = position.id:sub(first_separator)
		local a = test_name:find("::")
		if a then
			test_name = test_name:sub(0, a - 1)
		end
		-- if args.strategy == "dap" then
		-- 	test_name = test_name:gsub('^"', ""):gsub('"$', "")
		-- end

		test_name = escape_test_pattern(test_name)

		vim.list_extend(command, { "--filter='/^" .. test_name .. "$/'" })
	end

	-- BUG: Need to capture results after debugging the test
	-- TODO: Adding additional arguments breaks debugging
	-- need to determine if this is normal
	if args.strategy == "dap" then
		-- TODO: Allow users to specify an alternate port =HOST:PORT
		vim.list_extend(command, { "--inspect-brk" })

		strategy = {
			name = "Deno",
			type = config.get_dap_adapter(),
			request = "launch",
			cwd = "${workspaceFolder}",
			runtimeExecutable = "deno",
			runtimeArgs = table.concat(command, " "),
			port = 9229,
			protocol = "inspector",
		}
	end

	return {
		command = command,
		context = {
			results_path = results_path,
			position = position,
		},
		cwd = cwd,
		strategy = strategy,
	}
end

---@async
---@param spec neotest.RunSpec
---!param result neotest.StrategyResult
---!param tree neotest.Tree
---@return table<string, neotest.Result>
function DenoNeotestAdapter.results(spec)
	---@type table<string, neotest.Result>
	local results = {}
	local test_suite = ""
	local handle = assert(io.open(spec.context.results_path))
	---@type string
	local line = handle:read("l")

	-- TODO: ouput and short fields for failures
	while line do
		local test_name = utils.get_test_name(line)
		-- Remove namespace from test_suite
		if test_name and utils.ends_with(test_suite, "::" .. test_name .. "::") then
			test_suite = test_suite:sub(1, -#test_name - 3)
		end
		-- Next test suite
		if string.find(line, "running %d+ test") then
			-- local testfile = string.match(line, "running %d+ tests? from %.(.+%w+[sx]).-$")
			test_suite = utils.path_join(spec.cwd, spec.context.position.name) .. "::"
		-- Passed test
		elseif line:find("%.%.%. .*ok") then
			results[test_suite .. test_name] = { status = "passed", short }

		-- skipped test
		elseif line:find("%.%.%. .*ignored") then
			results[test_suite .. test_name] = { status = "skipped" }

		-- Failed test
		elseif line:find("%.%.%. .*FAILED") then
			results[test_suite .. test_name] = { status = "failed" }
		-- Add namespace to test_suite
		elseif line:find("%.%.%.") then
			test_suite = test_suite .. test_name .. "::"
		end

		line = handle:read("l")
	end

	if handle then
		handle:close()
	end

	return results
end

setmetatable(DenoNeotestAdapter, {
	__call = function(_, opts)
		if utils.is_callable(opts.args) then
			config.get_args = opts.args
		elseif opts.args then
			config.get_args = function()
				return opts.args
			end
		end
		if utils.is_callable(opts.allow) then
			config.get_allow = opts.allow
		elseif opts.allow then
			config.get_allow = function()
				return opts.allow
			end
		end
		if utils.is_callable(opts.root_files) then
			config.get_additional_root_files = opts.root_files
		elseif opts.root_files then
			config.get_additional_root_files = function()
				return opts.root_files
			end
		end
		if utils.is_callable(opts.filter_dirs) then
			config.get_additional_filter_dirs = opts.filter_dirs
		elseif opts.filter_dirs then
			config.get_additional_filter_dirs = function()
				return opts.filter_dirs
			end
		end
		if utils.is_callable(opts.dap_adapter) then
			config.get_dap_adapter = opts.dap_adapter
		elseif opts.dap_adapter then
			config.get_dap_adapter = function()
				return opts.dap_adapter
			end
		end
		return DenoNeotestAdapter
	end,
})

return DenoNeotestAdapter
