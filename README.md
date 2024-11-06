# neotest-deno

A [neotest](https://github.com/rcarriga/neotest) adapter for
[deno](https://deno.land/).

WIP

![neotest-deno1](https://user-images.githubusercontent.com/21696951/206565569-3d7b6489-da56-42e3-bf72-9b2599dc3a30.gif)

## Installation

Install and configure like any other neotest adapter:

### Lazy.nvim

```lua
{
  "nvim-neotest/neotest",
  dependencies = {
    ...,
    "markemmons/neotest-deno",
  },
  config = function()
    require("neotest").setup({
      ...,
      adapters = {
        require("neotest-deno"),
      }
    })
  end,
}
```

### LazyVim

```lua
{
  "nvim-neotest/neotest",
  dependencies = {
    "markemmons/neotest-deno",
  },
  opts = {
    adapters = {
      ["neotest-deno"] = {},
    },
  },

}
```

### Packer

```lua
use ({
  "nvim-neotest/neotest",
  requires= {
    ...,
    "markemmons/neotest-deno",
    config = function():
      ...,
      adapters = {
        require("neotes-deno")
      }
    end
  }
})
```

Requires [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter),
with the `typescript` parser installed.

```
:TSIntall typescript
```

## Configuration

TODO

## Test Support

- [x] Deno.test tests
- [x] Deno.test subtest
- [x] bdd - nested tests
- [ ] bdd - flat tests
- [x] Chai
- [x] Sinon.JS
- [x] fast-check
- [ ] Documentation tests
- [x] @std/expect

## DAP Support

![neotest-deno2](https://user-images.githubusercontent.com/21696951/206599082-2c1759d2-6158-41e5-9121-cb3bdb7fbe08.gif)

## Benchmarks

TODO

## Coverage

TODO
