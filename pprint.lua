local pprint = {}

-- TODO
-- some projects can override type() to return different types, should find a way to handle this

local TYPES = {
    'nil', 'boolean', 'number', 'string', 'table', 'function', 'thread', 'userdata'
}

pprint.defaults = {
    -- type display trigger
    show_nil = true,
    show_boolean = true,
    show_number = true,
    show_string = true,
    show_table = true,
    show_function = false,
    show_thread = false,
    show_userdata = false,
    -- additional display trigger
    show_metatable = false,
    show_all = false, -- override other show settings and show everything
    -- format settings
    indent = 4,
    wrap_string = true, -- wrap string when it's longer than level_width
    level_width = 120, -- max width per indent level
}

-- setup option with default
local function make_option(option)
    if option == nil then
        return pprint.defaults
    end
    for k, v in pprint.defaults do
        if option[k] == nil then
            option[k] = v
        end
        if option.show_all then
            for _, t in ipairs(TYPES) do
                option['show_'..t] = true
            end
            option.show_metatable = true
        end
    end
    return option
end

-- override defaults and take effects for all following calls
function pprint.setup(option)
    pprint.defaults = make_option(option)
end

-- format lua object into a string
function pprint.pformat(obj, option)
    option = make_option(option)
    local buf = {}
    local indent = ''
    local function _p(s, ...)
        table.insert(buf, indent..s:format(...))
    end

    local function _n()
        table.insert(buf, '\n')
    end

    local formatter = {}
    function tostring_formatter(v)
        _p(tostring(v))
    end

    for _, t in ipairs({'nil', 'boolean', 'number'}) do
        formatter[t] = tostring_formatter
    end

    local f = formatter[type(t)]
    f = f or formatter.table

    f(obj)

    return table.concat(buf, '')
end

-- pprint all the arguments
function pprint.pprint( ... )
    -- explicitly use #args to get the correct length
    -- ipairs stops halfway when the table contains nil
    local args = {...}
    for ix = 1,#args do
        print(pprint.pformat(args[ix]))
    end
end

setmetatable(pprint, {
    __call = function (_, ...)
        pprint.pprint(...)
    end
})

return pprint