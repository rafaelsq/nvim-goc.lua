local ts_utils = require "nvim-treesitter.ts_utils"

local M = {
  hi = vim.api.nvim_create_namespace("goc"),
  errBuf = nil,
}

M.Show = function()
  local source = {}
  for i, o in pairs(store) do
    table.insert(source, i .. '\t' .. table.concat(o.regcontents, "\n"))
  end

  local w = vim.fn["fzf#wrap"]('Yanks', {
    source = source,
  })
  w["sink*"] = function(line)
    local o = store[tonumber(string.gmatch(line[2], '%d+')())]
    vim.fn.setreg(vim.v.register, table.concat(o.regcontents, "\n"), o.regtype)
  end
  vim.fn["fzf#run"](w)
end

M.setup = function(opts)
  vim.highlight.link('GocNormal', 'Comment')
  vim.highlight.link('GocCovered', 'String')
  vim.highlight.link('GocUncovered', 'Error')
end

M.Coverage = function(fn)
  print('...')
  local fullPathFile = string.gsub(vim.api.nvim_buf_get_name(0), "_test", "")
  local bufnr = vim.uri_to_bufnr("file://." .. fullPathFile)

  local relativeFile = string.gsub(vim.fn.expand('%'), "_test", "")
  local package = vim.fn.expand('%:p:h')
  local tmp = vim.api.nvim_eval('tempname()')

  local h = nil

  local args = {'test', '-coverprofile', tmp, package}
  if fn then
    args = {'test', '-coverprofile', tmp, "-run", fn, package}
  end

  if M.errBuf ~= nil then
    vim.api.nvim_buf_delete(M.errBuf, {force=true})
  end
  M.errBuf = vim.api.nvim_create_buf(true, true)

  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  h = vim.loop.spawn('go', {args = args, stdio = {nil, stdout, stderr}}, vim.schedule_wrap(function(code, signal)
    M.ClearCoverage(bufnr)

    stdout:read_stop()
    stderr:read_stop()
    h:close()

    if code == 0 then
      if not vim.api.nvim_buf_is_loaded(bufnr) or #vim.fn.win_findbuf(bufnr) == 0 then
        vim.cmd("sp " .. string.gsub(fullPathFile, vim.fn.getcwd() .. '/', ''))
      end

      for i = 0,vim.fn.line('$') do
        vim.api.nvim_buf_add_highlight(bufnr, M.hi, "GocNormal", i, 0, -1)
      end

      local lines = vim.api.nvim_eval('readfile("' .. tmp .. '")')
      for i = 2,#lines do
        local path = string.gmatch(lines[i], '(.+):')()
        if string.find(path, relativeFile) then
          local marks = string.gmatch(lines[i], '%d+')

          local startline = tonumber(marks()) - 1
          local startcol = tonumber(marks()) - 1
          local endline = tonumber(marks()) -1
          local endcol = tonumber(marks())
          local numstmt = tonumber(marks())
          local cnt = tonumber(marks())

          local hig = "GocUncovered"
          if cnt == 1 then
            hig = "GocCovered"
          end

          for y = startline,endline do
            local sc = 0
            local ec = -1
            if startline == y then
              sc = startcol
            end
            if endline == y then
              ec = endcol
            end

            vim.api.nvim_buf_add_highlight(bufnr, M.hi, hig, y, sc, ec)
          end
        end
      end
    else
      if #vim.fn.win_findbuf(M.errBuf) == 0 then
        vim.cmd("vert sb " .. M.errBuf)
      end
    end
  end))

  local writeToScratch = function(err, data)
    vim.schedule(function()
      if err then
        vim.api.nvim_buf_set_lines(M.errBuf, -1, -1, false, vim.split(err, "\n"))
        return
      end
      if data then
        vim.api.nvim_buf_set_lines(M.errBuf, -1, -1, false, vim.split(data, "\n"))
      end
    end)
  end

  vim.loop.read_start(stdout, writeToScratch)
  vim.loop.read_start(stderr, writeToScratch)
end

M.CoverageFunc = function(p)
  if p == nil then
    p = ts_utils.get_node_at_cursor():parent()
  end
  if p:type() ~= "function_declaration" then
    M.CoverageFunc(p:parent())
    return
  end
  M.Coverage(string.gmatch(ts_utils.get_node_text(p)[1], 'Test[^%s%(]+')())
end

M.ClearCoverage = function(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, M.hi, 0, -1)
end

return M
