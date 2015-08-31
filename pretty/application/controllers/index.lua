local helpers = require 'gin.helpers.common'
local TestController = {}

function TestController:index()
	ngx.say('============hello vanilla===============')
end

function TestController:get()
    return 200, { message = "-------!" .. self.params.p }
end

function TestController:sendheader()
	-- ngx.log(ngx.ERR, '=============================' .. ngx.get_now_ts() .. '--' .. ngx.time())
	-- local cfg = ngx.config
	-- ngx.req.read_body()
	-- helpers.pp_to_file(ngx.req.read_body(), '/Users/zj-gin/sina/zj')
	-- ngx.log(ngx.ERR, cfg.nginx_configure())
	-- local params = self:accepted_params({ 'z', 'j' }, self.request.body)
	-- helpers.pp_to_file(params, '/Users/zj-gin/sina/zj')
	-- helpers.pp_to_file(self.request.ngx, '/Users/zj-gin/sina/zj')
	return 200, { message = "---fffvv----!-----"}, { ["Cache-Control"] = "max-age=1", ["Retry-After"] = "120" }
end

function TestController:fuck()
	-- helpers.pp_to_file(self, '/Users/zj-gin/sina/zj')
	if self.request.api_version == "1.0.2-rc1" then
		self:raise_error(1000, { missing_fields = { "first_name", "last_name" } })
		return 200, { message = "---xxxvv----!--" .. self.params[1]}
	else
		return 200, { message = "---nnxvv----!--" .. self.params[1]}
	end
end

function TestController:dopost()
	ngx.req.read_body()
	-- helpers.pp_to_file(ngx.req.get_body_data(), '/Users/zj-gin/sina/zj')
	local params = self:accepted_params({ 'name' }, self.request.body)
	-- helpers.pp_to_file(params, '/Users/zj-gin/sina/zj')
	return 200, { message = "---nnxvv----!--" .. self.params[1]}
end

return TestController