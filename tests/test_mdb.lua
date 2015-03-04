-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet
---------------------------------------------------------------------
-- @author Daniel Barney <daniel@pagodabox.com>
-- @copyright 2014, Pagoda Box, Inc.
-- @doc
--
-- @end
-- Created :   4 March 2015 by Daniel Barney <daniel@pagodabox.com>
---------------------------------------------------------------------

local tap = require('tap')
local LMDB = require('lmdb')

tap(function(test)
	test("Correct Version",function()
		local string,major,minor,patch = LMDB.version()
		assert(major == 0, "major")
		assert(minor == 9, "minor")
		assert(patch == 14 ,"patch")
		assert(type(string) == "string", "string")
	end)

	test("Error code lookup works",function()
		assert(LMDB.error(0) == nil, "0 should be nil")
		assert(type(LMDB.error(1)) == "string", "1 should have been an error")
	end)
end)