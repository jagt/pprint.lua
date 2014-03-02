local pprint = {}

pprint.defaults = {
    -- type display trigger, hide not useful datatypes by default
    -- custom types are treated as table
    show_nil = true,
    show_boolean = true,
    show_number = true,
    show_string = true,
    show_table = true,
    show_function = false,
    show_thread = false,
    show_userdata = false,
    -- additional display trigger
    show_metatable = false,    -- show metatable
    show_all = false,          -- override other show settings and show everything
    use_tostring = false,      -- use __tostring to print table if available
    filter_function = nil,     -- called like callback(value[,key]), return truty value to hide
    -- format settings
    indent_size = 2,           -- indent for each nested table level
    wrap_string = true,        -- wrap string when it's longer than level_width
    wrap_array = false,        -- wrap every array elements
    level_width = 80,          -- max width per indent level
    sort_keys = true,          -- sort table keys
}

local TYPES = {
    ['nil'] = 1, ['boolean'] = 2, ['number'] = 3, ['string'] = 4, 
    ['table'] = 5, ['function'] = 6, ['thread'] = 7, ['userdata'] = 8
}

-- seems this is the only way to escape these, as lua don't know how to char '\a' to 'a'
local ESCAPE_MAP = {
    ['\a'] = '\\a', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r',
    ['\t'] = '\\t', ['\v'] = '\\v', ['\\'] = '\\\\',
}

-- generic utilities
local function escape(s)
    s = s:gsub('([%c\\])', ESCAPE_MAP)
    local dq = s:find('"') 
    local sq = s:find("'")
    if dq and sq then
        return s:gsub('"', '\\"'), '"'
    elseif sq then
        return s, '"'
    else
        return s, "'"
    end
end

local function is_plain_key(key)
    return type(key) == 'string' and key:match('^[%a_][%a%d_]*$')
end

-- makes 'foo2' < 'foo100000'. string.sub makes substring anyway, no need to use index based method
local function str_natural_cmp(lhs, rhs)
    while #lhs > 0 and #rhs > 0 do
        local lmid, lend = lhs:find('[%d.]+')
        local rmid, rend = rhs:find('[%d.]+')
        if not (lmid and rmid) then return lhs < rhs end

        local lsub = lhs:sub(1, lmid-1)
        local rsub = rhs:sub(1, rmid-1)
        if lsub ~= rsub then
            return lsub < rsub
        end

        local lnum = tonumber(lhs:sub(lmid, lend))
        local rnum = tonumber(rhs:sub(rmid, rend))
        if lnum ~= rnum then
            return lnum < rnum
        end

        lhs = lhs:sub(lend+1)
        rhs = rhs:sub(rend+1)
    end
    return lhs < rhs
end

local function cmp(lhs, rhs)
    local tleft = type(lhs)
    local tright = type(rhs)
    if tleft == 'number' and tright == 'number' then return lhs < rhs end
    if tleft == 'string' and tright == 'string' then return str_natural_cmp(lhs, rhs) end
    if tleft == tright then return str_natural_cmp(tostring(lhs), tostring(rhs)) end

    -- allow custom types
    local oleft = TYPES[tleft] or 9
    local oright = TYPES[tright] or 9
    return oleft < oright
end

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
            for t, _ in pairs(TYPES) do
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
function pprint.pformat(obj, option, printer)
    option = make_option(option)
    local buf = {}
    local function default_printer(s)
        table.insert(buf, s)
    end
    printer = printer or default_printer

    local last = '' -- used for look back and remove trailing comma
    local status = {
        indent = '', -- current indent
        len = 0,     -- current line length
    }

    local wrapped_printer = function(s)
        printer(last)
        last = s
    end

    local function _indent(d)
        status.indent = string.rep(' ', d + #(status.indent))
    end

    local function _n(d)
        wrapped_printer('\n')
        wrapped_printer(status.indent)
        if d then
            _indent(d)
        end
        status.len = 0
        return true -- used to close bracket correctly
    end

    local function _p(s, nowrap)
        status.len = status.len + #s
        if not nowrap and status.len > option.level_width then
            _n()
            wrapped_printer(s)
            status.len = #s
        else
            wrapped_printer(s)
        end
    end

    local formatter = {}
    local function format(v)
        local f = formatter[type(v)]
        f = f or formatter.table -- allow patched type()
        if option.filter_function and option.filter_function(v, nil) then
            return ''
        else
            return f(v)
        end
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

    local function string_formatter(s, force_long_quote)
        local s, quote = escape(s)
        local quote_len = force_long_quote and 4 or 2
        if quote_len + #s + status.len > option.level_width then
            -- only wrap string when is longer than level_width
            if option.wrap_string and #s + quote_len > option.level_width then
                s = '[['..s..']]'
                while #s + status.len >= option.level_width do
                    local seg = option.level_width - status.len
                    _p(string.sub(s, 1, seg), true)
                    _n()
                    s = string.sub(s, seg+1)
                end
                return s -- return remaining part
            end
        end

        return force_long_quote and '[['..s..']]' or quote..s..quote
    end

    local function table_formatter(t)
        if option.use_tostring then
            local mt = getmetatable(t)
            if mt and mt.__tostring then
                return string_formatter(tostring(t), true)
            end
        end

        local tlen = #t
        local wrapped = false
        _p('{')
        _indent(option.indent_size)
        _p(string.rep(' ', option.indent_size - 1))
        for ix = 1,tlen do
            local v = t[ix]
            if formatter[type(v)] == nop_formatter or 
               (option.filter_function and option.filter_function(v, ix)) then
               -- pass
            else
                if option.wrap_array then
                    wrapped = _n()
                end
                _p(format(v)..', ')
            end
        end

        local function is_hash_key(k)
            local numkey = tonumber(k)
            if numkey ~= k or numkey > tlen then
                return true
            end
        end

        local function print_kv(k, v)
            -- can't use option.show_x as obj may contain custom type
            if formatter[type(v)] == nop_formatter or
               (option.filter_function and option.filter_function(v, k)) then
                return
            end
            wrapped = _n()
            if is_plain_key(k) then
                _p(k, true)
            else
                _p('[')
                _p(format(k), true)
                _p(']')
            end
            _p(' = ', true)
            _p(format(v), true)
            _p(',', true)
        end

        if option.sort_keys then
            local keys = {}
            for k, _ in pairs(t) do
                if is_hash_key(k) then
                    table.insert(keys, k)
                end
            end
            table.sort(keys, cmp)
            for _, k in ipairs(keys) do
                print_kv(k, t[k])
            end
        else
            for k, v in pairs(t) do
                if is_hash_key(k) then
                    print_kv(k, v)
                end
            end
        end

        if option.show_metatable then
            local mt = getmetatable(t)
            if mt then
                print_kv('__metatable', mt)
            end
        end

        _indent(-option.indent_size)
        -- make { } into {}
        last = string.gsub(last, '^ +$', '')
        -- peek last to remove trailing comma
        last = string.gsub(last, ',%s*$', ' ')
        if wrapped then
            _n()
        end
        _p('}')

        return ''
    end

    -- set formatters
    for _, t in ipairs({'nil', 'boolean', 'number'}) do
        formatter[t] = option['show_'..t] and tostring_formatter or nop_formatter
    end

    for _, t in ipairs({'function', 'thread', 'userdata'}) do
        formatter[t] = option['show_'..t] and make_fixed_formatter('[[ '..t..' ]]') or nop_formatter
    end

    formatter['string'] = option.show_string and string_formatter or nop_formatter
    formatter['table'] = option.show_table and table_formatter or nop_formatter

    _p(format(obj))
    printer(last) -- close the buffered one

    return table.concat(buf)
end

-- pprint all the arguments
function pprint.pprint( ... )
    -- explicitly use #args to get the correct length
    -- ipairs stops halfway when the table contains nil
    local args = {...}
    for ix = 1,#args do
        -- FIXME empty newline on non-shown elements
        pprint.pformat(args[ix], nil, io.write)
        print()
    end
end

setmetatable(pprint, {
    __call = function (_, ...)
        pprint.pprint(...)
    end
})

return pprint

