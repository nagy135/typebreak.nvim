# typebreak.nvim

![](https://tokei.rs/b1/github/nagy135/typebreak.nvim?category=code)

Take a brief break from current work and use it to speed up your typing speed.

# Install

use your favorite plugin manager:

```
Plug 'nagy135/typebreak.nvim'
```

# Usage

default bind `<leader>tb` opens new window, you enter insert mode with `i` and start typing words.
Words dissapear once you type them, and when all are gone, new batch shows.

If you wish to rebind it:
```
nnoremap <leader>tb :lua require("typebreak").start()<CR>
```
