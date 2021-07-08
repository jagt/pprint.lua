rockspec_format = "3.0"
package = "pprint"
version = "0.1-0"
description = {
  summary = "easy lua pretty printing, customizable and public domain!",
  detailed = [=[
pprint.lua is a friendly reimplementation of inspect.lua. pprint(whatever) in which whatever is anything you can find in Lua. It would dump it into a meaningful representation. Notably features:

* Limited customization through setting options.
* Sensible defaults, like not printing functions, userdatas, wrapping long lines etc.
* Printed results can be evaled (can't guaranteed to be identical as the original value).
* Tested on Lua 5.1, 5.2, 5.3 and Luajit 2.0.2.
* Released into the Public Domain, for whatever reason.

Example:

```lua
local pprint = require('pprint')
pprint(_G)
-- dumped _G to standard output:
-- { --[[table 1]]
--   _G = [[table 1]],
--   _VERSION = 'Lua 5.1',
--   arg = {},
--   coroutine = { --[[table 11]] },
--   debug = { --[[table 6]] },
--   io = { --[[table 7]] },
--   math = { --[[table 10]]
--     huge = 1.#INF,
--     pi = 3.1415926535898
--   },
--   os = { --[[table 8]] },
--   package = { --[[table 3]]
--   ... 
```
]=],
  license = "Public Domain",
  homepage = "https://github.com/kikito/inspect.lua",
  issues_url = "https://github.com/jagt/pprint.lua/issues",
  labels = {"debug"}
}
dependencies = {
  "lua >= 5.1, < 5.4"
}
source = {
  url = "git://github.com/jagt/pprint.lua",
  tag = "0.1"
}
build = {
  type = "builtin",
  modules = {
    pprint = "pprint.lua"
  }
}
