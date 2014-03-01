local pprint = {}

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
    indent_size = 4,
    wrap_string = true, -- wrap string when it's longer than level_width
    wrap_array = false, -- wrap every array elements
    level_width = 80, -- max width per indent level
    sort_keys = true, -- sort table keys
}

-- setup option with default
local function make_option(option)
    if option == nil then
        option = {}
    end
    for k, v in pairs(pprint.defaults) do
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
    local status = {
        indent = '', -- current indent
        len = 0,     -- current line length
    }

    local function _indent(d)
        status.indent = string.rep(' ', d + #(status.indent))
    end

    local function _n(d)
        table.insert(buf, '\n')
        table.insert(buf, status.indent)
        if d then
            _indent(d)
        end
        status.len = 0
    end

    local function _p(s, ...)
        local s = s:format(...)
        status.len = status.len + #s
        if status.len > option.level_width then
            _n()
            table.insert(buf, s)
            status.len = #s
        else
            table.insert(buf, s)
        end
    end

    local formatter = {}
    local function format(v)
        local f = formatter[type(v)]
        f = f or formatter.table -- allow patched type()
        return f(v)
    end

    local function tostring_formatter(v)
        return tostring(v)
    end

    local function nop_formatter(v)
        return ''
    end

    local function make_fixed_formatter(s)
        return function (v)
            return s
        end
    end

    local function string_formatter(s)
        return s
    end

    local function table_formater(t)
        local tlen = #t
        _p('{')
        _indent(1)
        for ix = 1,tlen do
            _p('%s, ', format(t[ix]))
            if option.wrap_array then
                _n()
            end
        end
        -- FIXME sort keys by providing a custom function
        for k, v in pairs(t) do
            local numkey = tonumber(k)
            if numkey ~= k or numkey > tlen then
                _p(format(k))
                _p(' = ')
                _p(format(v))
                _p(',')
            end
        end

        _p('}')
        _indent(-1)

        return ''
    end

    -- set formatters
    for _, t in ipairs({'nil', 'boolean', 'number'}) do
        formatter[t] = option['show_'..t] and tostring_formatter or nop_formatter
    end

    for _, t in ipairs({'function', 'thread', 'userdata'}) do
        formatter[t] = option['show_'..t] and make_fixed_formatter('[['..t..']]') or nop_formatter
    end

    formatter['string'] = option.show_string and string_formatter or nop_formatter
    formatter['table'] = option.show_table and table_formater or nop_formatter

    _p(format(obj))

    return table.concat(buf)
end

-- pprint all the arguments
function pprint.pprint( ... )
    -- explicitly use #args to get the correct length
    -- ipairs stops halfway when the table contains nil
    local args = {...}
    for ix = 1,#args do
        local s = pprint.pformat(args[ix])
        if #s > 0 then
            print(s)
        end
    end
end

setmetatable(pprint, {
    __call = function (_, ...)
        pprint.pprint(...)
    end
})

return pprint