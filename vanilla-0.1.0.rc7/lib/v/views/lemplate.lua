local Lemplate = {}
local templates = LoadApplication("views.templates")
function Lemplate:new(view_config)
    local instance = {
        view_config = view_config
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Lemplate:init(controller_name, action)
    self.controller_name = controller_name
    self.action = action
end

function Lemplate:process(key, stash)
    return table.concat(templates.process(key, stash))
end

function Lemplate:assign(params)
	return self:process(self.controller_name .. '-' .. self.action .. self.view_config.suffix, params)
end

return Lemplate