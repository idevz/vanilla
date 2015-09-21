-- vanilla
require 'vanilla.spec.init'

-- add integration runner
local IntegrationRunner = require 'vanilla.spec.runners.integration'

-- helpers
function cgi(request)
    return IntegrationRunner.cgi(request)
end
