# pprint.lua

__easy lua pretty printing, customizable and public domain!__

pprint.lua is a friendly reimplementation of [inspect.lua][1]. `pprint(whatever)` in which `whatever` is anything you can find in Lua. It would print all its data into a meaningful representation. Notablely features:

* Limited customization through setting options.
* Sensable defaults, like _not_ printing functions, userdatas, wrapping long lines etc.
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


## Usage

Grab [`pprint.lua`](pprint.lua) and drop it into your project. Then just require and start printing:

    local pprint = require('pprint')
    pprint({ foo = 'bar' })

If you're on LuaRocks then get [`inspect.lua`][1] instead. It's been around longer and more stable.

pprint.lua exposes `pprint` table with two other functions:

* `pprint(...)` : Print arguments given. If there's more than one then they are put into a table and printed.
* `pprint.pformat(obj[, option[, printer]])` : Return the string representation of `obj`. Provide `option` to override global settings during this invoke. `printer` will be called repeatly with string segments from the output. For example `pprint` uses `io.write` as printer.
* `pprint.setup(option)` : Setup global options. 
* `pprint.defaults` : Default settings. You can use `pprint(pprint.defaults)` to see what's in it. Notice that you shouldn't be writing to this directly.

## Options

You can configurate `pprint` behaviors by using `pprint.setup` or pass in a option table into `pformat`:

```lua
pprint.setup {
    show_all = true,
    wrap_array = true,
}
print(pprint.format(pprint.defaults, {sort_keys = false}))
```

Available options are:

* __show_{type}__ : skip values of given `type` when set to false. This includes the type of value as key, value or array element of a table. Defaults to show only `nil`, `boolean`, `number`, `string`.
* __show_metatable__ : whether showing metatable. Defaults to `false`.
* __show_all__ : show everything when set to `true`. It overrides all other `show` options. Defaults to `false`.
* __use_tostring__ : show table by using `__tostring` when available. Defaults to `true`.
* __filter_function__ : provide a function and it would be called as `func(v, k)`. `v` is the value. `k` is key or index, which isn't always available. Return truty values to skip showing this value. Here's an example for hiding empty tables:

    ```lua
    pprint.setup{filter_function = function(v, k)
        return type(v) == 'table' and not next(v)
    end}
    ```

* __object_cache__ : table might contain cyclic references and simply print all values would cause an infinite loop. __object_cache__ defaults to `local` so pprint would refer previously seen table with a short name. Set to `global` will cause the cache be kept between pprint invokes. Set to `nil` to disable, which might cause infinite loop.

    ```lua
    empty = {}
    d = {a=empty, b=empty, c=empty}
    pprint(d)
    -- {
    --   a = { --[[table 2]] },
    --   b = [[table 2]],
    --   c = [[table 2]]
    -- }
    ```

* __indent_size__ : indent size for each nested table. Defaults to `2`.
* __level_width__ : max width per indent level. Defaults to `80`.
* __wrap_string__ : break strings longer than __level_width__. Defaults to `true`.
    
    ```lua
    pprint.setup({level_width = 12, wrap_string = true})
    pprint('these are my twisted words.')
    -- [[these are
    -- my twisted w
    -- ords.]]
    ```

* __wrap_array__ : whether newline on array elements. Defaults to `false`.
* __sort_keys__ : natural-sort table keys for easier reading. Defaults to `true`.

## Bugs

0. There're no tests yet. (will be added soon.)
1. Combination of some settings might cause visual artifacts in the output.

## License

Public Domain

[1]:https://github.com/kikito/inspect.lua "inspect.lua"

