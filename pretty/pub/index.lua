local a = require 'vanilla.v.libs.utils'
function pp( ... )
    local helpers = require 'vanilla.v.libs.utils'
    helpers.pp(...)
    helpers.pp_to_file(..., '/Users/zj-git/vanilla/pretty/zj')
end
ngx.say('--===-=-')
-- ngx.eof()
app = require('vanilla.v.vanilla')
pp('app')

-- app.run()