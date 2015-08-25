function pp( ... )
    local helpers = require 'vanilla.v.libs.utils'
    helpers.pp(...)
    helpers.pp_to_file(..., '/Users/zj-git/vanilla/pretty/zj')
end
app = require('vanilla.v.application').new(require('config.application'))
app:run()