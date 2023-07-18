# nvim-goc.lua
easy go coverage

![image](https://user-images.githubusercontent.com/1598854/131515315-6178a680-cad1-4ccb-90e4-c61245f10b67.png)

## Setup

```lua

-- if set, when we switch between buffers, it will not split more than once. It will switch to the existing buffer instead
vim.opt.switchbuf = 'useopen'

local goc = require'nvim-goc'
goc.setup({ verticalSplit = false })  -- default to horizontal


vim.keymap.set('n', '<Leader>gcf', goc.Coverage, {silent=true})       -- run for the whole File
vim.keymap.set('n', '<Leader>gct', goc.CoverageFunc, {silent=true})   -- run only for a specific Test unit
vim.keymap.set('n', '<Leader>gcc', goc.ClearCoverage, {silent=true})  -- clear coverage highlights

-- If you need custom arguments, you can supply an array as in the example below.
-- vim.keymap.set('n', '<Leader>gcf', function() goc.Coverage({ "-race", "-count=1" }) end, {silent=true})
-- vim.keymap.set('n', '<Leader>gct', function() goc.CoverageFunc({ "-race", "-count=1" }) end, {silent=true})

vim.keymap.set('n', ']a', goc.Alternate, {silent=true})
vim.keymap.set('n', '[a', goc.AlternateSplit, {silent=true})          -- set verticalSplit=true for vertical

cf = function(testCurrentFunction)
  local cb = function(path)
    if path then

      -- `xdg-open|open` command performs the same function as double-clicking on the file.
      -- change from `xdg-open` to `open` on MacOSx
      vim.cmd(":silent exec \"!xdg-open " .. path .. "\"")
    end
  end

  if testCurrentFunction then
    goc.CoverageFunc(nil, cb, 0)
  else
    goc.Coverage(nil, cb)
  end
end

-- If you want to open it in your browser, you can use the commands below.
-- You need to create a callback function to configure which command to use to open the HTML.
-- On Linux, `xdg-open` is generally used, on MacOSx it's just `open`.
vim.keymap.set('n', '<leader>gca', cf, {silent=true})
vim.keymap.set('n', '<Leader>gcb', function() cf(true) end, {silent=true})

-- default colors
-- vim.api.nvim_set_hl(0, 'GocNormal', {link='Comment'})
-- vim.api.nvim_set_hl(0, 'GocCovered', {link='String'})
-- vim.api.nvim_set_hl(0, 'GocUncovered', {link='Error'})
```
