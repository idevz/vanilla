local Appconf={}

Appconf.route=require('vanilla.v.routes.simple').new()
Appconf.app={}
Appconf.app.root='/Users/zj-git/vanilla/pretty/'

Appconf.controller={}
Appconf.controller.path=Appconf.app.root .. 'application/controllers/'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. 'application/views/'
Appconf.view.suffix='.html'

return Appconf