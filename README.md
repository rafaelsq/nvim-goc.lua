# nvim-goc.lua
easy go coverage

![image](https://user-images.githubusercontent.com/1598854/131515315-6178a680-cad1-4ccb-90e4-c61245f10b67.png)

## Setup

```lua

-- if set, when we switch between buffers, it will not split more than once. It will switch to the existing buffer instead
vim.opt.switchbuf = 'useopen'

local goc = require'nvim-goc'
goc.setup({ verticalSplit = false })


vim.keymap.set('n', '<Leader>gcr', goc.Coverage, {silent=true})
vim.keymap.set('n', '<Leader>gcc', goc.ClearCoverage, {silent=true})
vim.keymap.set('n', '<Leader>gct', goc.CoverageFunc, {silent=true})
vim.keymap.set('n', ']a', goc.Alternate, {silent=true})
vim.keymap.set('n', '[a', goc.AlternateSplit, {silent=true})

cf = function(testCurrentFunction)
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

vim.keymap.set('n', '<leader>gca', cf, {silent=true})
vim.keymap.set('n', '<Leader>gcb', function() cf(true) end, {silent=true})

-- default colors
-- vim.highlight.link('GocNormal', 'Comment')
-- vim.highlight.link('GocCovered', 'String')
-- vim.highlight.link('GocUncovered', 'Error')
```
