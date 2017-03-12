-- vanilla
LoadV 'vanilla.spec.init'

-- add integration runner
local IntegrationRunner = LoadV 'vanilla.spec.runners.integration'

-- helpers
function cgi(request)
    return IntegrationRunner.cgi(request)
end
