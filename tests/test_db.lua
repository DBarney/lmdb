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


tap(function(test,setup,teardown)
	local db,env
	setup(function()
		env = LMDB.create_env()
		local err = env:set_maxdbs(10)
		assert(not err,err)
		assert(env, "Env was created")
		err = env:open('./tests/fixtures/db',env.MDB_NOSUBDIR,0755)
		assert(not err,err)
		local txn,err = env:begin_txn(nil,0)
		assert(not err,err)
		db,err = txn:open_db("test",LMDB.DB.MDB_CREATE)
		assert(not err,err)
		err = txn:commit()
		assert(not err,err)
	end)

	teardown(function()
		os.remove('./tests/fixtures/db')
		os.remove('./tests/fixtures/db-lock')
		env:close()
	end)

	test("get db flags",function()
		local flags,err = db:flags()
		assert(not err,err)
		assert(not (flags == nil),"flags should not be nil")
	end)

	test("get db stats",function()
		local stats,err = db:stat()
		assert(not err,err)
		assert(not (stats == nil),"stats should not be nil")
		assert(stats.ms_psize,"stats.ms_psize doesn't exist")
		assert(stats.ms_depth,"stats.ms_depth doesn't exist")
		assert(stats.ms_branch_pages,"stats.ms_branch_pages doesn't exist")
		assert(stats.ms_leaf_pages,"stats.ms_leaf_pages doesn't exist")
		assert(stats.ms_overflow_pages,"stats.ms_overflow_pages doesn't exist")
		assert(stats.ms_entries,"stats.ms_entries doesn't exist")
	end)

	test("can drop db",function()
		local err = db:drop()
		local err = db:drop(true)
	end)
end)