local Console = {}

function Console.start()
	local lua = 'lua'
	-- if VANILLA_JIT_BIN ~= nil then
	-- 	lua = VANILLA_JIT_BIN
	-- end
    local cmd = lua .. " -i -e \"_PROMPT='v-console>';package.path='" .. package.path 
              .. "' package.cpath='" .. package.cpath 
              .. "' LoadV 'vanilla.sys.config';LoadV 'vanilla.v.libs.utils'\""
    os.execute(cmd)
end

return Console