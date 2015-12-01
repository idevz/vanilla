local Console = {}

function Console.start()
    local cmd = "lua -i -e \"package.path='" .. package.path 
              .. "' package.cpath='" .. package.cpath 
              .. "' require 'vanilla.sys.config';require 'vanilla.v.libs.utils'\""
    os.execute(cmd)
end

return Console