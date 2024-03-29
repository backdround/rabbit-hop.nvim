# Rabbit-hop.nvim

<p align="center">
  <a href="https://github.com/backdround/rabbit-hop.nvim/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/backdround/rabbit-hop.nvim/tests.yaml?branch=main&label=Tests&style=flat-square" alt="Tests">
  </a>
  <a href="https://github.com/backdround/rabbit-hop.nvim/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/backdround/rabbit-hop.nvim/docs.yaml?branch=main&label=Doc%20generation&status=gen&style=flat-square" alt="Tests">
  </a>
</p>

It's a Neovim plugin that provides a flexible ability to hop to a user
defined vim-pattern (quotes, brackets, numbers).

Hops work:

- in multiline;
- in `normal`, `visual`, `operator-pending` and `insert` modes;
- with non-ascii text;
- with the `count` multiplier;
- with the `dot` repetition.

The plugin:

- Can be used as api for other plugins;
- Should be stable in corner cases (has lots of tests).

<!-- panvimdoc-ignore-start -->

***

### Preview
#### Hop inside / outside round brackets
<img src="https://github.com/backdround/rabbit-hop.nvim/assets/17349169/bb300bcd-2b87-448c-bb13-483659f456af" width="600px" />

#### Hop inside / outside quotes
<img src="https://github.com/backdround/rabbit-hop.nvim/assets/17349169/d615afb0-810f-4327-9a07-fa14fdadd9c7" width="600px" />

#### Hop to a number
<img src="https://github.com/backdround/rabbit-hop.nvim/assets/17349169/60596f0c-c513-458c-80dc-734bf3d3f609" width="600px" />

***

<!-- panvimdoc-ignore-end -->

### Configuration example
```lua
local rh = require("rabbit-hop")

-- Hop forward inside round brackets.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    match_position = "end",
    offset = 1,
    pattern = "\\M(",
  })
end)

-- Hop backward inside round brackets.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    match_position = "start",
    offset = -1,
    pattern = "\\M)",
  })
end)
```

### Additional configuration examples
<details><summary>Hop to a number</summary>

```lua
-- Hop forward to the start of a number.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    match_position = "start",
    pattern = "\\v\\d+",
  })
end)

-- Hop backward to the start of a number.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    match_position = "start",
    pattern = "\\v\\d+",
  })
end)
```

</details>

<details><summary>Hop inside / outside quotes</summary>

```lua
-- Hop forward past quotes.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    match_position = "end",
    offset = 1,
    pattern = "\\v[\"'`]",
  })
end)

-- Hop backward past quotes.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    match_position = "start",
    offset = -1,
    pattern = "\\v[\"'`]",
  })
end)
```

</details>

<details><summary>Hop inside / outside round brackets</summary>

```lua
-- Hop forward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    match_position = "end",
    offset = 1,
    pattern = "\\v[()]",
    -- If you don't want to hop past ) which is the last character on the line,
    -- then use this pattern: "\\v((|\\)$@!)"
  })
end)

-- Hop backward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    match_position = "start",
    offset = -1,
    pattern = "\\v[()]",
  })
end)
```

</details>

<!-- panvimdoc-ignore-start -->

***

<!-- panvimdoc-ignore-end -->

### Plugin API
```lua
local hop = require("rabbit-hop").hop

--- `performed` (boolean) Indicates that the hop has been performed.
--- `options` (RH_PluginOptions) Adjust the behavior of the hop.
local performed = hop(options)
```

#### `RH_PluginOptions`:
| Option | Default | Possible | Description |
| --- | --- | --- | --- |
| `pattern` | - | any vim pattern | Pattern to hop. |
| `direction?` | `"forward"` | `"forward"`, `"backward"` | Direction to hop. |
| `match_position?` | `"start"` | `"start"`, `"end"` | Sets which end of the match to use. |
| `offset?` | 0 | any number | Advances final position relatively `match_position`. |
| `insert_mode_target_side?` | `"left"` | `"left"`, `"right"` | Side to place the cursor in insert mode. It's applied after all offsets.
| `accept_policy?` | `"from-after-cursor"` | `"from-after-cursor"`, `"from-cursor"`, `"any"` | Indicates whether a potential position should be accepted.
| - | - | `"from-after-cursor"` | Accepts all positions in the direction of the hop after the cursor.
| - | - | `"from-cursor"` | Accepts the position at the cursor and all positions in the direction of the hop after the cursor.
| - | - | `"any"` | Accepts all positions even if a position moves the cursor backward from hop direction.
| `fold_policy?` | `"hop-once"` | `"ignore"`, `"hop-once"`, `"hop-in-and-open"` | Decides how to deal with folds.
| - | - | `"hop-once"` | Accept a position in a fold only once. If there is no position in a fold then hops through.
| - | - | `"ignore"` | Ignores all potential positions in folds.
| - | - | `"hop-in-and-open"` | Accepts all positions in folds. If a target position is in a fold then, hops at it and opens the fold.
