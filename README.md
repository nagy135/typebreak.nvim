# typebreak.nvim

![](https://tokei.rs/b1/github/nagy135/typebreak.nvim?category=code)

![screen](doc/header_screen.png)

<!-- <details> -->
<!-- <summary>Screencast asciinema</summary> -->
<!-- ![asciicast](https://asciinema.org/a/Bmn6XjaE2tuTeAcB3D69pZBWn.svg) -->
<!-- </details> -->

<details>
<summary>Summary stats</summary>
<img width="700" alt="Summary stats" src="doc/stats_screen.png">
</details>

Take a brief break from current work and use it to speed up your typing speed.

# Install

Use your favorite plugin manager to install it. The refreshed version uses current Neovim APIs and targets Neovim 0.10+.

Plug
```viml
Plug 'nagy135/typebreak.nvim'
```

Packer
```lua
use { 'nagy135/typebreak.nvim' }

-- with binding

use { 'nagy135/typebreak.nvim',
    config = function()
        vim.keymap.set('n', '<leader>tb', require('typebreak').start, { desc = "Typebreak" })
    end
}
```

# Usage

Bind it first! (using setup section bellow), doesnt bind to anything by default.

Pressing bind opens new floating window with words and puts you in insert mode.
You can instantly start typing and words are getting highlighted as you type them, then dissapear.
Once you type them all, you see summary prompt with stats and option to play again.
Close the window whenever you want <kbd>ctrl</kbd> + <kbd>w</kbd>, <kbd>q</kbd>

# Setup
Bind start function to some key

``` viml
nnoremap <leader>tb :lua require("typebreak").start()<CR>
```
```lua
vim.keymap.set('n', '<leader>tb', require('typebreak').start, { desc = "Typebreak" })

```

# Custom dictionary
By default it tries to fetch random words from a remote API and falls back to the shipped local dictionary if that fails. If you want to force the local dictionary, you need to do following:

First you simply pass true to start function
```lua
require("typebreak").start(true)
```

Or better, bind it
```lua
vim.keymap.set('n', '<leader><leader>tb', function() require('typebreak').start(true) end, { desc = "Typebreak (local dictionary)" })
```
```viml
nnoremap <leader><leader>tb :lua require("typebreak").start(true)<CR>
```

This uses 200 words long dictionary shipped with plugin.

If you want to extend or replace those words you need to call `setup()` any time before calling `start()`
```lua
require('typebreak').setup({
    ["dictionary"] = {"tik", "tak", "toe"},
    -- also boolean flag if you want to replace default ones with your own only
    -- ["replace_dictionary"] = true
})
```
