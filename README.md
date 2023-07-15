# 🍞 breadcrumbs.nvim

breadcrumbs is a plugin that works with nvim-navic to provide context about your code in the winbar.

## Install

Add the following plugins with your favorite plugin manager

```
"SmiteshP/nvim-navic",
"LunarVim/breadcrumbs.nvim"
```

## Setup

```lua
  require("nvim-navic").setup {
    lsp = {
      auto_attach = true,
    },
}

require("breadcrumbs").setup()
```

## TODO

- setup options
