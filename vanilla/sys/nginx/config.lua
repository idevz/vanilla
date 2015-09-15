-- perf
local ogetenv = os.getenv

local index_tpl = [[
<!DOCTYPE html>
<html>
<body>
  <h1>{{message}}</h1>
  <h1>{{kk}}</h1>
  <h5>{{zhou}}</h5>
</body>
</html>
]]

local NgxConf = {}

-- environment
NgxConf.env = ogetenv("VA_ENV") or 'development'

-- directories
NgxConf.directives = {
	[''] = init_by_lua,
}

NgxConf.settings = settings.for_environment(NgxConf.env)

return NgxConf
