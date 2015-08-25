function pp( ... )
    local helpers = require 'vanilla.v.libs.utils'
    helpers.pp(...)
    helpers.pp_to_file(..., '/Users/zj-git/vanilla/pretty/zj')
end
app = require('vanilla.v.application').new(ngx, require('config.application'))
pp(app)
app:run()