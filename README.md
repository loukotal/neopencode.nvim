# neopencode.nvim

A Neovim plugin to interact with [opencode.ai](https://opencode.ai).

Name is not great, but didn't want to sit on `opencode.nvim`

> [!warning]
> Proof of concept. And 100% opencoded.
> Most probably doesn't work with multiple instances of opencode running

## Features

- List and select opencode.ai sessions.
- Send the current filename to an opencode.ai session.
- Send the selected lines to an opencode.ai session.

## Installation

Use your favorite plugin manager.

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "loukotal/neopencode.nvim",
  config = function()
    require("neopencode.main")
  end,
}
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "loukotal/neopencode.nvim",
  config = function()
    require("neopencode.main")
  end,
}
```

## Usage

- `:OpencodeSelectSession` - Select an active opencode.ai session.
- `:OpencodeFile` - Send the current file to the selected session.
- `:OpencodeSelect` - Send the selected lines to the selected session.

## Configuration

You can configure the plugin by calling the `setup` function.

```lua
require("neopencode.main").setup({
  -- your configuration options here
})
```

(No configuration options are available yet.)
