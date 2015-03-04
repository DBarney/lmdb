-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet
---------------------------------------------------------------------
-- @author Daniel Barney <daniel@pagodabox.com>
-- @copyright 2014, Pagoda Box, Inc.
-- @doc
--
-- Based on TAP.
-- @end
-- Created :   4 March 2015 by Daniel Barney <daniel@pagodabox.com>
---------------------------------------------------------------------

local tests = {}

local run_tests = function(tests)

end

return function(suite)
	if suite == true then
		local sucessful,fail,skipped = 0,0,0
		local count = 1
		local continue = false
		for _,group in pairs(tests) do
			if group.setup then
				local sucess,err = pcall(group.setup)
				if not sucess then
					continue = true
					print(err)
				end
			end
			for idx,test in ipairs(group) do
				local name,test = unpack(test)
				local skip = false
				local skip_test = function()
					skip = true
					assert(false)
				end
				if continue then
					print("not ok ".. count .. " skipped "..name)
					skipped = skipped + 1
				else
					local sucess,err = pcall(test,skip_test)
					if sucess then
						print("ok ".. count .. " success "..name)
						sucessful = sucessful + 1
					elseif skip then
						print("not ok ".. count .. " skipped "..name)
						skipped = skipped + 1
					else
						print(err:sub(6)) -- eat the .////
						print("not ok ".. count .. " failure "..name)
						fail = fail + 1
					end
				end
				count = count + 1
			end
			if group.teardown then
				assert(pcall(group.teardown))
			end
		end
		print()
		print("successful tests: " .. sucessful .. ' failed tests: '..fail..' skipped tests: '..skipped)
	else
		local group = {}
		local setup = function(fn)
			group.setup = fn
		end
		local teardown = function(fn)
		group.teardown = fn
		end
		tests[#tests + 1] = group

		suite(function(name,test)
			group[#group + 1] = 
				{name,test}
		end,setup,teardown)
	end
end