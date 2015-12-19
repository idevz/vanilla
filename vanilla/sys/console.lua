local Console = {}

function Console.start()
	local lua = 'lua'
	if VANILLA_JIT_BIN ~= nil then
		lua = VANILLA_JIT_BIN
	end
    local cmd = lua .. " -i -e \"package.path='" .. package.path 
              .. "' package.cpath='" .. package.cpath 
              .. "' require 'vanilla.sys.config';require 'vanilla.v.libs.utils'\""
    os.execute(cmd)
end

return Console