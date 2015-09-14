-- local UserService = require('vanilla.v.model.service'):new()
local table_dao = require('application.models.dao.table'):new()
local UserService = {}

function UserService:get()
	table_dao:set('zhou', 'j')
	return table_dao.zhou
end

return UserService