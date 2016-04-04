require('spec.helper')

describe("Dispatcher", function()
    before_each(function()
        Application = require 'vanilla.v.application'
        Dispatcher = require 'vanilla.v.dispatcher'
        Controller = require 'vanilla.v.controller'
        Request = require 'vanilla.v.request'
        Response = require 'vanilla.v.response'
        View = require 'vanilla.v.views.rtpl'
        Error = require 'vanilla.v.error'
        Plugin = require 'vanilla.v.plugin'

        application = Application:new(ngx, config)
        dispatcher = Dispatcher:new(application)
        request = Request:new()
        response = Response:new()
        plugin = Plugin:new()
    end)

    after_each(function()
        package.loaded['vanilla.v.application'] = nil
        package.loaded['vanilla.v.dispatcher'] = nil
        package.loaded['vanilla.v.controller'] = nil
        package.loaded['vanilla.v.request'] = nil
        package.loaded['vanilla.v.response'] = nil
        package.loaded['vanilla.v.views.rtpl'] = nil
        package.loaded['vanilla.v.error'] = nil
        package.loaded['vanilla.v.plugin'] = nil
        Application = nil
        Dispatcher = nil
        Controller = nil
        Request = nil
        Response = nil
        View = nil
        Error = nil
        Plugin = nil

        application = nil
        dispatcher = nil
        request = nil
        response = nil
        plugin = nil
    end)

    describe("#new", function()
        it("creates a new instance of a dispatcher with application", function()
            assert.are.same(application, dispatcher.application)
        end)
    end)

    describe("#getRequest", function()
        it("get a request instance", function()
            assert.are.same(request, dispatcher.request)
        end)
    end)

    describe("#setRequest", function()
        it("set a request instance", function()
            assert.are.same(request, dispatcher.request)
        end)
    end)

    describe("#getResponse", function()
        it("get a response instance", function()
            assert.are.same(response, dispatcher.response)
        end)
    end)

    describe("#setResponse", function()
        it("set a response instance", function()
            assert.are.same(response, dispatcher.response)
        end)
    end)

    describe("#registerPlugin", function()
        it("register a plugin to app", function()
            assert.are.same(plugin, dispatcher.plugins)
        end)
    end)

    -- describe("#_router", function()
    --     it("raises an error with a code", function()
    --         local ok, err = pcall(function() controller:raise_error(1000) end)

    --         assert.are.equal(false, ok)
    --         assert.are.equal(1000, err.code)
    --     end)

    --     it("raises an error with a code and custom attributes", function()
    --         local custom_attrs = { custom_attr_1 = "1", custom_attr_2 = "2" }
    --         local ok, err = pcall(function() controller:raise_error(1000, custom_attrs) end)

    --         assert.are.equal(false, ok)
    --         assert.are.equal(1000, err.code)
    --         assert.are.same(custom_attrs, err.custom_attrs)
    --     end)
    -- end)

    -- describe("#dispatch", function()
    --     before_each(function()
    --         local Response = require 'gin.core.response'
    --         response = Response.new({
    --             status = 200,
    --             headers = { ['one'] = 'first', ['two'] = 'second' },
    --             body = { name = 'gin'}
    --         })
    --     end)

    --     it("sets the ngx status", function()
    --         Router.respond(ngx, response)

    --         assert.are.equal(200, ngx.status)
    --     end)
    -- end)
end)