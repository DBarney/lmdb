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

local check_err = function(err)
	assert(not err,err)
end

tap(function(test,setup,teardown)
	local env
	setup(function()
		env = LMDB.create_env()
		assert(env, "Env was created")
		check_err(env:open('./tests/fixtures/env',env.MDB_NOSUBDIR,0755))
		
	end)

	teardown(function()
		os.remove('./tests/fixtures/env')
		os.remove('./tests/fixtures/env-lock')
		env:close()
	end)

	test("Stat an env",function()
		local stat,err = env:stat()
		check_err(err)
		assert(stat, "stat failed")
		assert(not (stat.ms_psize == nil), "ms_psize is missing")
		assert(not (stat.ms_depth == nil), "ms_depth is missing")
		assert(not (stat.ms_branch_pages == nil), "ms_branch_pages is missing")
		assert(not (stat.ms_leaf_pages == nil), "ms_leaf_pages is missing")
		assert(not (stat.ms_overflow_pages == nil), "ms_overflow_pages is missing")
		assert(not (stat.ms_entries == nil), "ms_entries is missing")
	end)

	test("Info an env",function()
		local info,err = env:info()
		check_err(err)
		assert(info, "info failed")
		-- this is nil for some reason
		-- assert(not (info.me_mapaddr == nil), "me_mapaddr is missing")
		assert(not (info.me_mapsize == nil), "me_mapsize is missing")
		assert(not (info.me_last_pgno == nil), "me_last_pgno is missing")
		assert(not (info.me_last_txnid == nil), "me_last_txnid is missing")
		assert(not (info.me_maxreaders == nil), "me_maxreaders is missing")
		assert(not (info.me_numreaders == nil), "me_numreaders is missing")
	end)

	test("Copy to path",function()
		check_err(env:copy('./tests/fixtures/open.backup'))
		os.remove('./tests/fixtures/open.backup')
	end)

	test("Sync sucess",function()
		check_err(env:sync(true))
		check_err(env:sync(false))
	end)

	test("Can set max dbs",function()
		local env = LMDB.create_env()
		check_err(env:set_maxdbs(10))
		env:close()
	end)

	local get_set = function(id,get,set)
		return function()
			local ret,err = env[get](env)
			check_err(err)
			assert(ret,get ..' failed')
			if set then
				local err = env[set](env,ret)
				assert(not err, id ..": ".. err)
			end
		end
	end
	local funcs = 
		{["check flags"] = {'get_flags','set_flags'}
		,["get path"] = {'get_path'}
		,["get fd"] = {'get_fd'}
		,["check maxreaders"] = {'get_maxreaders','set_maxreaders'}
		,["get maxkeysize"] = {'get_maxkeysize'}
		,["perform reader_check"] = {'reader_check'}}

	for id,funs in pairs(funcs) do
		test(id,get_set(id,unpack(funs)))
	end
end)