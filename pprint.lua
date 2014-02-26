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

-- print aribitrary lua object
function pprint.pformat(obj, option)
    option = make_option(option)
    local buf = {}

end

-- pprint all the arguments
function pprint.pprint( ... )

end


return pprint