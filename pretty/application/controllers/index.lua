local IndexController = {}

function IndexController:index()
	local view = self:getView()
	local req = self:getRequest()
	local p = {}
	p['message'] = 'K'
	p['kk'] = tservice:get()
	view:assign(p)
	view:assign('zhou', 'jing')
	return view:display()
end

function IndexController:index2()
	local view = self:getView()
	-- view:render('index/index.html', {message = '============'})
	-- pp(view:caching(true))
	local resp = self:getResponse()
	-- resp:setHeader('Content_type', 'application/json')
	view:assign('message', '-----------')
	view:assign('kk', '------xxx-----')
	-- view:assign()
	view:display()
	-- return 200, { message = "-------!" .. self.params.p }
end

function IndexController:get()
	local view = self:getView()
	-- view:render('index/index.html', {message = '============'})
	-- pp(view:caching(true))
	view:assign('message', '-----------')
	-- view:assign()
	-- view:display()
	-- return 200, { message = "-------!" .. self.params.p }
end

function IndexController:sendheader()
    -- local view = template.new "index/index.html"
    -- view[key] = value
    -- pp(view)
    -- view:render()
    -- ngx.eof()
    -- pp(key .. value)
end

function IndexController:fuck()
	if self.request.api_version == "1.0.2-rc1" then
		self:raise_error(1000, { missing_fields = { "first_name", "last_name" } })
		return 200, { message = "---xxxvv----!--" .. self.params[1]}
	else
		return 200, { message = "---nnxvv----!--" .. self.params[1]}
	end
end

function IndexController:dopost()
	ngx.req.read_body()
	local params = self:accepted_params({ 'name' }, self.request.body)
	return 200, { message = "---nnxvv----!--" .. self.params[1]}
end

return IndexController