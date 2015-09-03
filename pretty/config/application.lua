local Appconf = {}

Appconf.route = require('vanilla.v.routes.simple').new()
Appconf.app_root = '/Users/zj-git/vanilla/pretty/'
Appconf.controller_path = Appconf.app_root .. 'application/controllers/'
Appconf.view_path = Appconf.app_root .. 'application/views/'

return Appconf