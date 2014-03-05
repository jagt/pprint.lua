print '-- basics'

-- reused in following tests
_G.simple = {
    ['nil'] = nil,
    ['boolean'] = true,
    ['number'] = 253,
    ['string'] = 'and my head is my only house unless it rains.',
    ['empty-table'] = {},
    ['simple-array'] = {1, 2, 3, 4, 5},
    ['simple-dict'] = {a=1, b=2, c=3},
    ['function'] = function()end,
    ['thread'] = {__type='thread'},
    ['userdata'] = {__type='userdata'},
}

test('emtpy table', function()
assert_str_equal(pprint.pformat({}), '{}')
end)

test('single element dict', function()
assert_str_equal(pprint.pformat({a=2}),
[[{ 
  a = 2
}]])
end)

test('simple with default settings', function()
assert_str_equal(pprint.pformat(simple), [[
{
  boolean = true,
  ['empty-table'] = {},
  number = 253,
  ['simple-array'] = { 1, 2, 3, 4, 5 },
  ['simple-dict'] = { 
    a = 1,
    b = 2,
    c = 3
  },
  string = 'and my head is my only house unless it rains.'
}
]])
end)

test('simple show_all', function()
assert_str_equal(pprint.pformat(simple, {show_all = true}), [===[
{
  boolean = true,
  ['empty-table'] = {},
  function = [[function 1]],
  number = 253,
  ['simple-array'] = { 1, 2, 3, 4, 5 },
  ['simple-dict'] = {
    a = 1,
    b = 2,
    c = 3
  },
  string = 'and my head is my only house unless it rains.',
  thread = [[thread 1]],
  userdata = [[userdata 1]]
}
]===])
end)

-- '[['' and ']] can't be wraped in between
test('wrap strings', function()
assert_str_equal(
    pprint.pformat(
        'these are my twisted words.',
        {level_width = 10, wrap_string = true}
    ),
[==[[[these ar
e my twist
ed words.
]]]==])
end)

test('show custom type as table', function()
local t = {1, 2, 3, 4, 5, __type = 'moon' }
assert_str_equal(type(t), 'moon')
assert_str_equal(
pprint.pformat(t),
[[
{ 1, 2, 3, 4, 5,
  __type = 'moon'
}
]]
)
end)


test('simple nested table', function()
local empty = {}
local t = {a=empty, b=empty, c=empty}
assert_str_equal(pprint.pformat(t),
[===[
{
  a = { --[[table 2]] },
  b = [[table 2]],
  c = [[table 2]]
}
]===])
end)

-- _G should be complex enough
test('eval pformat _G', function()
local s = loadstring('return '..pprint.pformat(s, {show_all = true}))()
end)


test('identify hash key', function()
local t = {1, 2, 3, [5] = 5}
assert_str_equal(pprint.pformat(t),
[===[
{ 1, 2, 3,
  [5] = 5
}
]===])
end)