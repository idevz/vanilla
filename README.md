#vanilla
### One bouquet of vanilla
*Vanilla is An Opentresty Web Framework For PHPER.*
<p><a href="http://idevz.github.io/vanilla/"><img border="0" src="http://m1.sinaimg.cn/maxwidth.300/m1.sinaimg.cn/ca65fa784406a36ba4fc41d14e21661e_1364_1494.png" alt="LuaRocks" width="150px"></a></p>

##install
```
yum install lua-devel luarocks
luarocks install https://raw.githubusercontent.com/idevz/vanilla/master/vanilla-0.0.1-1.rockspec
```

##set
```
content_by_lua_file ./pub/index.lua;
```

##useage
```
vanilla new app
cd app
vanilla start
```