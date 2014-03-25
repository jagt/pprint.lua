print '-- regression'

test('natural cmp on multiple dots', function()
pprint.pformat{["22..a....333"] = 2, ["33a......444"] = 3}
end)

