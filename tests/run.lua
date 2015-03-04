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
package.path = './?.lua;./tests/?.lua;' .. package.path
local tap = require('tap')

function load_tests(dir)
  local p = io.popen('find "'..dir..'" -type f -name \'test_*.lua\'')
  for file in p:lines() do
    assert(require(file:sub(1,-5)))
  end
end

load_tests('./')
-- run all the tests
tap(true)