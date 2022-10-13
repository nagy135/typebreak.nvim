# typebreak.nvim

![](https://tokei.rs/b1/github/nagy135/typebreak.nvim?category=code)

![screen](screen.png)
![screen_summary](screen_summary.png)

Take a brief break from current work and use it to speed up your typing speed.

# Install

use your favorite plugin manager:

Plug
```viml
Plug 'nagy135/typebreak.nvim'
```

Packer
```lua
use 'nagy135/typebreak.nvim'

-- with binding

use { 'nagy135/typebreak.nvim',
    config = function()
        vim.keymap.set('n', '<leader>tb', require('typebreak').start, { desc = "Typebreak" })
    end
}
```

# Usage

Bind it first (using setup section bellow), doesnt bind to anything by default.

Bind opens new window, where you are instantly in insert mode and can start typing words you see.
Words dissapear once you type them, and when type them all, you get report of how much time it took you and option to play 10 more words.
When you done with it just close the buffer <kbd>ctrl</kbd> + <kbd>w</kbd>, <kbd>q</kbd>

# Setup
Bind start function to some key

``` viml
nnoremap <leader>tb :lua require("typebreak").start()<CR>
```
```lua
vim.keymap.set('n', '<leader>tb', require('typebreak').start, { desc = "Typebreak" })
```
