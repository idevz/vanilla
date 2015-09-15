-- local UserService = require('vanilla.v.model.service'):new()
local table_dao = require('application.models.dao.table'):new()
local http = require('vanilla.v.libs.http'):new()
local json = require 'cjson'
local jdecode = json.decode
local UserService = {}

function UserService:get()
	table_dao:set('zhou', 'j')
	-- (url, method, params, headers, timeout)
	-- local headers = {}
	-- headers['User-Agent'] = 'zhoujing'
	-- local rs = http:get('http://i.falcon.sina.cn/ht?zhoujing', 'GET', nil, headers, 200)
	-- ppz('<pre />')
	-- ppz(jdecode(rs.body))
	return table_dao.zhou
end

return UserService