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
    require("neopencode.main").setup()
  end,
}
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "loukotal/neopencode.nvim",
  config = function()
    require("neopencode.main").setup({
      -- follows https://models.dev/
      -- needs to be setup in opencode
      provider_id = "google",
      model_id = "gemini-2.5-pro-preview-06-05",
    })
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
  provider_id = "google",
  model_id = "gemini-2.5-pro-preview-06-05",
})
```

## TODOs

- [ ] better session picking
- [ ] there should not be a setup for the model, it should use whatever the session was using
- [ ] there should be a way to select a model that is set up in opencode - so you can use a different model for each message when needed
- [ ] creating a new session does not update opencode ui and the session needs to be selected in opencode
