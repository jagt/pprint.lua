# pprint.lua

__easy lua pretty printing, customizable and public domain!__

pprint.lua is a friendly reimplementation of [inspect.lua][1]. `pprint(whatever)` in which `whatever` is anything you can find in Lua. It would print all its data into a meaningful representation. Notablely features:

* Limited customization through setting options.
* Sensable defaults, like _not_ printing functions, userdatas, wrapping long lines etc.
* Released into the Public Domain, for whatever reason.

## Usage

Grab [`pprint.lua`](pprint.lua) and drop it into your project. Then just require and start printing:

    local pprint = require('pprint')
    pprint({ foo = 'bar' })

If you're on LuaRocks then get [`inspect.lua`][1] instead. It's been around longer and more stable.

## Options

TODO

## Bugs

1. Combination of some settings would cause visual artifacts in the output.

## License

Public Domain

[1]:https://github.com/kikito/inspect.lua "inspect.lua"

