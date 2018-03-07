print '-- regression'

test('natural cmp on multiple dots', function()
pprint.pformat{["22..a....333"] = 2, ["33a......444"] = 3}
end)

test("non positive integer keys shouldn't be dropped", function()
local t = { [-1]="baz", [0] = "foo", [1] = "bar", [0.8] = "foz" }
assert_str_equal(pprint.pformat(t),
[===[
{ 'bar',
  [-1] = 'baz',
  [0] = 'foo',
  [0.8] = 'foz'
}]===])
end)




