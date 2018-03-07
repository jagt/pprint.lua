print '-- options'

test('show almost nothing', function()
assert_str_equal(pprint.pformat(simple, {
    show_nil = false,
    show_boolean = false,
    show_number = false,
    show_string = false,
    show_table = true,
    show_function = false,
    show_thread = false,
    show_userdata = false,
    depth_limit = false
}),
[[
{}
]]
)
end)

test('show metatable', function()
local t = {}
setmetatable(t, {1, 2, 3})
assert_str_equal(pprint.pformat(t, {
    show_metatable = true,
}),
[[
{
  __metatable = { 1, 2, 3 }
}
]]
)
end)

test('use tostring', function()
local t = {}
setmetatable(t, {__tostring = function() return 'a string' end})
assert_str_equal(pprint.pformat(t, {
    use_tostring = true,
}),
[==[
[[a string]]
]==]
)
end)

test('filter function', function()
local parent = {'target', key = 'target', target = 'value'}
local t = {
    target = t,
    nontarget = { -- this one shouldn't be hidden
        'target',
        key = 'target',
        target = 'value'
    }
}
assert_str_equal(pprint.pformat(t, {
    filter_function = function(v, k, t)
        return t == parent and v == 'target'
    end, 
}),
[==[
{
  nontarget = { 'target',
    key = 'target',
    target = 'value'
  }
}
]==]
)
end)

local inner = { foo = 'bar' }
local cache_test = {
    inner, inner,
    key = inner
}

test('object cache - false', function()
assert_str_equal(pprint.pformat(cache_test, {
    object_cache = false,
}),
[[
{ {
    foo = 'bar'
  }, {
    foo = 'bar'
  },
  key = {
    foo = 'bar'
  }
}
]]
)
end)

test('object cache - global', function()
assert_str_equal(pprint.pformat(cache_test, {
    object_cache = 'global',
}),
[===[
{ { --[[table 2]]
    foo = 'bar'
  }, [[table 2]],
  key = [[table 2]]
}
]===]
)
-- second call should be quite different
assert_str_equal(pprint.pformat(cache_test, {
    object_cache = 'global',
}),
[===[
{ --[[table 1]] [[table 2]], [[table 2]],
  key = [[table 2]]
}
]===]
)
end)

test('object cache - local', function()
assert_str_equal(pprint.pformat(cache_test, {
    object_cache = 'local',
}),
[===[
{ { --[[table 2]]
    foo = 'bar'
  }, [[table 2]],
  key = [[table 2]]
}
]===]
)
end)

test('indent size', function()
assert_str_equal(pprint.pformat(cache_test, {
    indent_size = 4,
}),
[===[
{   {   --[[table 2]]
        foo = 'bar'
    }, [[table 2]],
    key = [[table 2]]
}
]===]
)
end)

test('level width', function()
local longer = string.rep('long ', 5)
local t = {
    longer = longer,
    {longer, longer}
}
assert_str_equal(pprint.pformat(t, {
    level_width = 10,
}),
[===[
{ {
    [[long lon
    g long lon
    g long
    ]],
    [[long lon
    g long lon
    g long
    ]] },
  longer =
  [[long lon
  g long lon
  g long ]]
}
]===]
)
end)

test('wrap string', function()
local longer = string.rep('longer_', 20)
assert_str_equal(pprint.pformat(longer, {
    wrap_string = true,
}),
[===[
[[longer_longer_longer_longer_longer_longer_longer_longer_longer_longer_longer_l
onger_longer_longer_longer_longer_longer_longer_longer_longer_]]
]===]
)
end)

test('wrap string disabled', function()
local longer = string.rep('longer_', 20)
assert_str_equal(pprint.pformat(longer, {
    wrap_string = false,
}),
"'"..longer.."'"
)
end)

test('wrap array', function()
local arr = {1,2,3,4,5}
assert_str_equal(pprint.pformat(arr, {
    wrap_array = true,
}),
[===[
{
  1,
  2,
  3,
  4,
  5
}
]===]
)
end)

test('wrap array disabled', function()
local arr = {1,2,3,4,5}
assert_str_equal(pprint.pformat(arr, {
    wrap_array = false,
}),
[===[
{ 1, 2, 3, 4, 5 }
]===]
)
end)

test('sort keys', function()
local t = { book1 = 'book1', book10 = 'book10', book2 = 'book2' }
assert_str_equal(pprint.pformat(t, {
    sort_keys = true
}),
[[
{
  book1 = 'book1',
  book2 = 'book2',
  book10 = 'book10'
}
]]
)
end)

test('depth_limit', function ()
local a = { 1, 2, 3, 4, 5 }
local t = { a, { a }}

assert_str_equal(pprint.pformat(t, { depth_limit=2 }),
[==[ { { --[[table 2]] 1, 2, 3, 4, 5 }, { [[table 2]] } } ]==])

assert_str_match(pprint.pformat(t, { depth_limit=1 }),
[==[{%-%[%[table%-2%]%]%.%.%.,%-%[%[table:%-%w+%]%]%-}]==])

assert_str_match(pprint.pformat(t, { depth_limit=0 }),
[==[%[%[table:%-%w+%]%]]==])

a = { book1 = 'book1', book10 = 'book10', book2 = 'book2' }
t = { a, { a }}

assert_str_equal(pprint.pformat(t, { depth_limit=2 }),
[==[
{ { --[[table 2]]
    book1 = 'book1',
    book2 = 'book2',
    book10 = 'book10'
  }, { [[table 2]] } }
]==])

assert_str_match(pprint.pformat(t, { depth_limit=1 }),
[==[{%-%[%[table%-2%]%]%.%.%.,%-%[%[table:%-%w+%]%]%-}]==])

assert_str_match(pprint.pformat(t, { depth_limit=0 }),
[==[%[%[table:%-%w+%]%]]==])

end)

-- it's actually quite difficult to test unsorted, as we must ensure it's as
-- the same as the pairs order, which is different in lua51/52/jit
--[===[
test('sort keys disabled', function()
local t = { book1 = 'book1',  book10 = 'book10', book2 = 'book2'}
assert_str_equal(pprint.pformat(t, {
    sort_keys = false    
})
[[
{
  book1 = 'book1',
  book2 = 'book2',
  book10 = 'book10'
}
]]
)
end)

]===]
