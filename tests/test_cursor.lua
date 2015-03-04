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
	local db,env,cursor,txn
	setup(function()
		env = LMDB.create_env()
		assert(env, "Env was created")
		local err = env:set_maxdbs(10)
		assert(not err,err)
		err = env:open('./tests/fixtures/cursor',env.MDB_NOSUBDIR,0755)
		assert(not err,err)
		local txn1,err = env:begin_txn(nil,0)
		assert(not err,err)
		assert(txn1,"unable to create txn")
		local db1,err = txn1:open_db("test",LMDB.DB.MDB_CREATE + LMDB.DB.MDB_DUPSORT)
		assert(not err,err)
		assert(db1,"unable to open database")
		for i=1,10 do
			for j=1,10 do
				assert(txn1:put("test",i,"data:" .. j,0) == nil,"unable to insert test data")
			end
		end
		err = txn1:commit()
		assert(not err,err)

		txn,err = env:begin_txn(nil,0)
		assert(not err,err)
		assert(txn,"unable to begin txn")
		db,err = txn:open_db("test",LMDB.DB.MDB_DUPSORT)
		assert(not err,err)
		assert(db,"unable to open db")
		cursor,err = db:open_cursor()
		assert(not err,err)
		assert(cursor,"unable to open cursor")
		print(cursor)
	end)

	teardown(function()
		os.remove('./tests/fixtures/cursor')
		os.remove('./tests/fixtures/cursor-lock')
		txn:abort()
		env:close()
	end)

	test("can open and close a cursor",function(skip) 
		local cursor,err = db:open_cursor()
		assert(not err,err)
		assert(cursor,"unable to open cursor")
		err = cursor:close()
		assert(not err,err)
		cursor = nil
	end)

	test("cursor MDB_FIRST",function(skip)
		skip()
		print(cursor)
		-- MDB_FIRST Position at first key/data item
		local idx,data,err = cursor:first()
		print(cursor)
		assert(not err,err)
		print(tostring(idx),data,err)
		assert(idx == 1,"index was wrong ")
		assert(data == "data:1","data was wrong for index")
	end)

	test("cursor MDB_NEXT",function(skip)
		skip()
		-- MDB_NEXT Position at next data item
		local idx,data,err = cursor:next()
		assert(not err,err)
		assert(idx == 2,"index was wrong")
		assert(data == "data:10","data was wrong for index")
	end)

	test("cursor MDB_PREV",function(skip)
		skip()
		-- MDB_PREV Position at previous data item
		local idx,data,err = cursor:prev()
		assert(not err,err)
		assert(idx == 1,"index was wrong")
		assert(data == "data:1","data was wrong for index")
	end)

	test("cursor MDB_SET",function(skip)
		skip()
		-- MDB_SET Position at specified key
		local idx,data,err = cursor:set(4)
		assert(not err,err)
		assert(idx == 4,"index was wrong")
		assert(data == "data:4","data was wrong for index")
	end)

	test("cursor MDB_SET_KEY",function(skip)
		skip()
		-- MDB_SET_KEY Position at specified key, return key + data
		local idx,data,err = cursor:set_key(7)
		assert(not err,err)
		assert(idx == 7,"index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)


	test("cursor MDB_FIRST_DUP",function(skip)
		skip()
		-- MDB_FIRST_DUP Position at first data item of current key. Only for MDB_DUPSORT
		local idx,data,err = cursor:first_dup(7)
		assert(not err,err)
		assert(idx == "7","index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)

	test("cursor MDB_GET_BOTH",function(skip)
		skip()
		-- MDB_GET_BOTH Position at key/data pair. Only for MDB_DUPSORT
		local idx,data,err = cursor:get_both("7")
		assert(not err,err)
		assert(idx == "7","index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)

	test("cursor MDB_GET_BOTH_RANGE",function(skip)
		skip()
		-- MDB_GET_BOTH_RANGE position at key, nearest data. Only for MDB_DUPSORT
		local idx,data,err = cursor:set_key("7")
		assert(not err,err)
		assert(idx == "7","index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)

	test("cursor MDB_GET_CURRENT",function(skip)
		skip()
		-- MDB_GET_CURRENT Return key/data at current cursor position
		local idx,data,err = cursor:current()
		assert(not err,err)
		assert(idx == "7","index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)

	test("cursor MDB_GET_MULTIPLE",function(skip)
		skip()
		-- MDB_GET_MULTIPLE Return key and up to a page of duplicate data items from current cursor position. Move cursor to prepare for MDB_NEXT_MULTIPLE. Only for MDB_DUPFIXED
		local idx,data,err = cursor:set_key("7")
		assert(not err,err)
		assert(idx == "7","index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)

	test("cursor MDB_LAST",function(skip)
		skip()
		-- MDB_LAST Position at last key/data item
		local idx,data,err = cursor:last()
		assert(not err,err)
		assert(idx == 10,"index was wrong")
		assert(data == "data:1","data was wrong for index")
	end)

	test("cursor MDB_LAST_DUP",function(skip)
		skip()
		-- MDB_LAST_DUP Position at last data item of current key. Only for MDB_DUPSORT
		local idx,data,err = cursor:last_dup()
		assert(not err,err)
		assert(idx == 10,"index was wrong")
		assert(data == "data:10","data was wrong for index")
	end)

	test("cursor MDB_PREV_DUP",function(skip)
		skip()
		-- MDB_PREV_DUP Position at previous data item of current key. Only for MDB_DUPSORT
		local idx,data,err = cursor:prev_dup("7")
		assert(not err,err)
		assert(idx == 10,"index was wrong")
		assert(data == "data:9","data was wrong for index")
	end)

	test("cursor MDB_NEXT_DUP",function(skip)
		skip()
		-- MDB_NEXT_DUP Position at next data item of current key. Only for MDB_DUPSORT
		local idx,data,err = cursor:next_dup("7")
		assert(not err,err)
		assert(idx == 10,"index was wrong")
		assert(data == "data:10","data was wrong for index")
	end)

	test("cursor MDB_NEXT_MULTIPLE",function(skip)
		skip()
		-- MDB_NEXT_MULTIPLE Return key and up to a page of duplicate data items from next cursor position. Move cursor to prepare for MDB_NEXT_MULTIPLE. Only for MDB_DUPFIXED
		local idx,data,err = cursor:set_key("7")
		assert(not err,err)
		assert(idx == "7","index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)

	test("cursor MDB_NEXT_NODUP",function(skip)
		skip()
		-- MDB_NEXT_NODUP Position at first data item of next key
		local idx,data,err = cursor:next_nodup()
		assert(not err,err)
		assert(idx == "7","index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)

	test("cursor MDB_PREV_NODUP",function(skip)
		skip()
		-- MDB_PREV_NODUP Position at last data item of previous key
		local idx,data,err = cursor:prev_nodup("7")
		assert(not err,err)
		assert(idx == "7","index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)

	test("cursor MDB_SET_RANGE",function(skip)
		skip()
		-- MDB_SET_RANGE Position at first key greater than or equal to specified key.
		local idx,data,err = cursor:set_range(7)
		assert(not err,err)
		assert(idx == 7,"index was wrong")
		assert(data == "data:7","data was wrong for index")
	end)
end)