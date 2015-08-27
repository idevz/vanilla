local routes = require 'gin.core.routes'

-- define version
local v1 = routes.version(1)

-- define routes
v1:GET("/", { controller = "pages", action = "root" })
v1:GET("/test/header", { controller = "test", action = "sendheader" })
v1:GET("/test/:p", { controller = "test", action = "get" })
v1:GET("/test/(.*)", { controller = "test", action = "fuck" })

v1:POST("/test/post", {controller = "test", action = "dopost"})

return routes
