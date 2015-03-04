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
	local env
	setup(function()
		env = LMDB.create_env()
		local err = env:set_maxdbs(10)
		assert(not err,err)
		assert(env, "Env was created")
		err = env:open('./tests/fixtures/txn',env.MDB_NOSUBDIR,0755)
		assert(not err,err)
	end)

	teardown(function()
		os.remove('./tests/fixtures/txn')
		os.remove('./tests/fixtures/txn-lock')
		env:close()
	end)

	test("can open and abort a transaction",function() 
		local txn,err = env:begin_txn(nil,0)
		assert(not err,err)
		assert(txn,"unable to create a transaction")
		txn:abort()
	end)

	test("can open and commit a transaction",function() 
		local txn,err = env:begin_txn(nil,0)
		assert(not err,err)
		assert(txn,"unable to create a transaction")
		err = txn:commit()
		assert(not err,err)
	end)

	test("can open and reset a transaction",function(skip)
		skip() 
		-- resetting needs to be special
		local txn,err = env:begin_txn(nil,0)
		assert(not err,err)
		assert(txn,"unable to create a transaction")
		txn:reset()
	end)

	test("can create a db in a transaction",function() 
		local txn,err = env:begin_txn(nil,0)
		assert(not err,err)
		assert(txn,"unable to create a transaction")
		local db,err = txn:open_db("test",LMDB.DB.MDB_CREATE)
		assert(not err,err)
		assert(db,"unable to open a database")
		txn:commit()
	end)

	test("insert get and del work correctly",function() 
		local txn,err = env:begin_txn(nil,0)
		assert(not err,err)
		assert(txn,"unable to create a transaction")
		txn:put("test","foo","bar",0)
		txn:commit()
		txn:renew()
		assert(txn:get("test","foo") == "bar","data point was not right")
		txn:abort()
		txn,err = env:begin_txn(nil,0)
		assert(not err,err)
		err = txn:del("test","foo")
		assert(not err,err)
		err = txn:commit()
		assert(not err,err)
	end)
end)