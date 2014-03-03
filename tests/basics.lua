local simple = {
    ['nil'] = nil,
    ['boolean'] = true,
    ['number'] = 253,
    ['string'] = 'and my head is my only house unless it rains.',
    ['empty-table'] = {},
    ['simple-array'] = {1, 2, 3, 4, 5},
    ['simple-dict'] = {a=1, b=2, c=3},
    ['function'] = test,
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

-- TODO really should be doing this by eval
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