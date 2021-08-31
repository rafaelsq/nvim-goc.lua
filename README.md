# nvim-goc.lua
easy go coverage

![image](https://user-images.githubusercontent.com/1598854/131515315-6178a680-cad1-4ccb-90e4-c61245f10b67.png)

## Setup

```lua
local goc = require'nvim-goc'
goc.setup()

vim.api.nvim_set_keymap('n', '<Leader>gcr', ':lua require("nvim-goc").Coverage()<CR>', {silent=true})
vim.api.nvim_set_keymap('n', '<Leader>gcc', ':lua require("nvim-goc").ClearCoverage()<CR>', {silent=true})
vim.api.nvim_set_keymap('n', '<Leader>gct', ':lua require("nvim-goc").CoverageFunc()<CR>', {silent=true})
vim.api.nvim_set_keymap('n', '<Leader>gca', ':lua cf(false)<CR><CR>', {silent=true})
vim.api.nvim_set_keymap('n', '<Leader>gcb', ':lua cf(true)<CR><CR>', {silent=true})

_G.cf = function(testCurrentFunction)
  local cb = function(path)
    if path then
      vim.cmd(":silent exec \"!xdg-open " .. path .. "\"")
    end
  end

  if testCurrentFunction then
    goc.CoverageFunc(nil, cb, 0)
  else
    goc.Coverage(nil, cb)
  end
end

-- default colors
-- vim.highlight.link('GocNormal', 'Comment')
-- vim.highlight.link('GocCovered', 'String')
-- vim.highlight.link('GocUncovered', 'Error')
```
