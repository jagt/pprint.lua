-- never try writing tests from scratch, it's not worth it.
package.path = package.path..';../pprint.lua'
local pprint = require('pprint')

local pass = true
local case = 1
local function test(title, fun)
    io.write(string.format('%d: %s ... ', case, title))
    local bt
    local success = xpcall(fun, function (err)
        bt = debug.traceback(err, 2)
    end)
    io.write(success and 'ok\n' or 'failed!\n')
    if not success then
        io.write(bt..'\n')
        pass = false
    end
    case = case + 1
end

-- patch type() so that it reads t.__type for type
local oldtype = type
local function newtype(obj)
    local t = oldtype(obj)
    if t == 'table' then
        return obj.__type and obj.__type or 'table'
    else
        return t
    end
end

-- remove trailing spaces and visualize all spaces
local function normalize(s)
    return s:match("^[%s]*(.-)[%s]*$"):gsub(' *\n', '\n'):gsub(' ', '-')
end

function assert_str_equal(lhs, rhs)
    lhs = normalize(lhs)
    rhs = normalize(rhs)
    if lhs ~= rhs then
        error(string.format('string equal failed!\ntrimed lhs:\n>>>\n%s\n<<<\ntrimed rhs:\n>>>\n%s\n<<<\n', lhs, rhs), 2)
    end
end

function assert_str_match(str,pat)
   str=normalize(str)
   if not string.match(str,pat) then
      error(string.format('pattern match failed!\ntrimmed string:\n>>>\n%s\n<<<\npattern:\n>>>\n%s\n<<<\n', str, pat), 2)
   end
end

_G.pprint = pprint
_G.type = newtype
_G.test = test
_G.assert_str_equal = assert_str_equal
if not _G.loadstring then
    _G.loadstring = load
end

dofile('./basics.lua')
dofile('./options.lua')
dofile('./regression.lua')

io.write(string.format('executed %d cases. passed: %s\n', case - 1, tostring(pass)))
os.exit(pass and 0 or 1)
