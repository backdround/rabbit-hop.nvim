# Rabbit-hop.nvim
It's a Neovim plugin that provides a flexible ability to jump to a user
defined vim-pattern (quotes, brackets, numbers).

Jumps work:
- in multiline;
- in `normal`, `visual`, `operator-pending` and `insert` modes;
- with non-ascii text;
- with the `count` multiplier;
- with the `dot` repetition.

The plugin:
- Can be used as api for other plugins;
- Should be stable in corner cases (has lots of tests).

<!-- panvimdoc-ignore-start -->

### Preview

---

<!-- panvimdoc-ignore-end -->

### Configuration example
```lua
local rh = require("rabbit-hop")

-- Hop forward inside round brackets.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    offset = "post",
    pattern = "\\M(",
  })
end)

-- Hop backward inside round brackets.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    offset = "post",
    pattern = "\\M)",
  })
end)
```

### Additional configuration examples
<details><summary>Hop to a number</summary>

```lua
-- Hop forward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    offset = "start",
    pattern = "\\v\\d+",
  })
end)

-- Hop backward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    offset = "start",
    pattern = "\\v\\d+",
  })
end)
```

</details>

<details><summary>Hop inside / outside quotes</summary>

```lua
-- Jump forward past quotes.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    offset = "post",
    pattern = "\\v[\"'`]",
  })
end)

-- Jump backward past quotes.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    offset = "post",
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
    offset = "post",
    pattern = "\\v[()]",
    -- If you don't want to jump past ) which is the last character on the line,
    -- then use this pattern: "\\v((|\\)$@!)"
  })
end)

-- Hop backward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    offset = "post",
    pattern = "\\v[()]",
  })
end)
```

</details>


### Plugin hop options

| Option | Default | Possible | Description |
| --- | --- | --- | --- |
| `direction` | `"forward"` | `"forward"`, `"backward"` | Direction to jump |
| `pattern` | - | any vim pattern | Pattern to jump |
| `offset` | `"start"` | `"pre"`, `"start"`, `"end"`, `"post"` | Cursor position relative to the pattern |
| `insert_mode_target_side` | `"left"` | `"left"`, `"right"` | Side to place the cursor in insert mode. It's applied after the offset.