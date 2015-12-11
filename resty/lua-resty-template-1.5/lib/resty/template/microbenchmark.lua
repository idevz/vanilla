local template = require "resty.template"

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

local function run(iterations)
    local total, print, parse, compile, iterations, clock = 0, ngx and ngx.say or print, template.parse, template.compile, iterations or 1000, os.clock

    local view = [[
    <ul>
    {% for _, v in ipairs(context) do %}
        <li>{{v}}</li>
    {% end %}
    </ul>]]

    print(string.format("Running %d iterations in each test", iterations))

    local x = clock()
    for i = 1, iterations do
        parse(view, true)
    end
    local z = clock() - x
    print(string.format("    Parsing Time: %.6f", z))
    total = total + z

    x = clock()
    for i = 1, iterations do
        compile(view, nil, true)
        template.cache = {}
    end
    z = clock() - x
    print(string.format("Compilation Time: %.6f (template)", z))
    total = total + z

    compile(view, nil, true)

    x = clock()
    for i = 1, iterations do
        compile(view, 1, true)
    end
    z = clock() - x
    print(string.format("Compilation Time: %.6f (template cached)", z))
    total = total + z

    local context = { "Emma", "James", "Nicholas", "Mary" }

    template.cache = {}

    x = clock()
    for i = 1, iterations do
        compile(view, 1, true)(context)
        template.cache = {}
    end
    z = clock() - x
    print(string.format("  Execution Time: %.6f (same template)", z))
    total = total + z

    template.cache = {}
    compile(view, 1, true)

    x = clock()
    for i = 1, iterations do
        compile(view, 1, true)(context)
    end
    z = clock() - x
    print(string.format("  Execution Time: %.6f (same template cached)", z))
    total = total + z

    template.cache = {}

    local views = new_tab(iterations, 0)
    for i = 1, iterations do
        views[i] = "<h1>Iteration " .. i .. "</h1>\n" .. view
    end

    x = clock()
    for i = 1, iterations do
        compile(views[i], i, true)(context)
    end
    z = clock() - x
    print(string.format("  Execution Time: %.6f (different template)", z))
    total = total + z

    x = clock()
    for i = 1, iterations do
        compile(views[i], i, true)(context)
    end
    z = clock() - x
    print(string.format("  Execution Time: %.6f (different template cached)", z))
    total = total + z

    template.cache = {}
    local contexts = new_tab(iterations, 0)

    for i = 1, iterations do
        contexts[i] = {"Emma " .. i, "James " .. i, "Nicholas " .. i, "Mary " .. i }
    end

    x = clock()
    for i = 1, iterations do
        compile(views[i], i, true)(contexts[i])
    end
    z = clock() - x
    print(string.format("  Execution Time: %.6f (different template, different context)", z))
    total = total + z

    x = clock()
    for i = 1, iterations do
        compile(views[i], i, true)(contexts[i])
    end
    z = clock() - x
    print(string.format("  Execution Time: %.6f (different template, different context cached)", z))
    total = total + z
    print(string.format("      Total Time: %.6f", total))
end

return {
    run = run
}