local Appconf={}
Appconf.name = 'pretty'

Appconf.route='vanilla.v.routes.simple'
Appconf.bootstrap='application.bootstrap'

Appconf.app={}
Appconf.app.root='../' .. Appconf.name .. '/'

Appconf.controller={}
Appconf.controller.path=Appconf.app.root .. 'application/controllers/'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. 'application/views/'
Appconf.view.suffix='.html'
Appconf.view.auto_render=true

return Appconf