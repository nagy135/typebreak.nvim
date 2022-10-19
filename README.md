# typebreak.nvim

![](https://tokei.rs/b1/github/nagy135/typebreak.nvim?category=code)

![screen](doc/header_screen.png)

<details>
<summary>Screencast asciinema</summary>

![asciicast](https://asciinema.org/a/Bmn6XjaE2tuTeAcB3D69pZBWn.svg)

</details>

<details>
<summary>Summary stats</summary>
<img width="700" alt="Summary stats" src="doc/stats_screen.png">
</details>

Take a brief break from current work and use it to speed up your typing speed.

# Install

use your favorite plugin manager to install with [plenary](https://github.com/nvim-lua/plenary.nvim) as dependency:

Plug
```viml
Plug 'nagy135/typebreak.nvim'
Plug 'nvim-lua/plenary.nvim'
```

Packer
```lua
use { 'nagy135/typebreak.nvim', requires = 'nvim-lua/plenary.nvim' }

-- with binding

use { 'nagy135/typebreak.nvim',
    requires = 'nvim-lua/plenary.nvim',
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
