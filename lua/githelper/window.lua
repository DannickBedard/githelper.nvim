-- TODOS :windowwindow
-- - [ ] Make logique to navigate between sections
-- ...

local api = vim.api
local buf, win
local resumerBuffer, resumerWin
local position = 0

local border = require("githelper.border")
local windowHelper = require("githelper.windowHelper")
local currentBorder = border.doubleBorder


local function open_window()
  buf = api.nvim_create_buf(false, true)
  local border_buf = api.nvim_create_buf(false, true)

  api.nvim_set_option_value('bufhidden', 'wipe', {buf = buf})
  api.nvim_set_option_value('filetype', 'whid', {buf = buf})

  local width = api.nvim_win_get_width(0)
  local height = api.nvim_win_get_height(0)

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)



  local opts = {
    -- style = "minimal",
    relative = "editor",
    width = win_width ,
    height = math.ceil(win_height),
    row = row,
    col = col,
    border = 'single'
  }

  local border_opts = {
    style = "minimal",
    relative = "editor",
    width = win_width + 2,
    height = win_height + 2,
    col = (vim.o.columns - width) / 2,
  }


  -- local currentBorder = border.simpleBorder
  -- local border_lines = {}
  -- local top_border =  currentBorder[border.CORNER_LEFT_TOP] .. string.rep(currentBorder[border.SIDE_BOTTOM], win_width) .. currentBorder[border.CORNER_RIGHT_TOP] 
  -- local bottom_border =  currentBorder[border.CORNER_LEFT_BOTTOM] .. string.rep(currentBorder[border.SIDE_BOTTOM], win_width) .. currentBorder[border.CORNER_RIGHT_BOTTOM] 
  -- local middle_line =  currentBorder[border.SIDE] .. string.rep(' ', win_width) .. currentBorder[border.SIDE] 

  -- table.insert(border_lines, top_border)

  -- for i=1, win_height do
  --   table.insert(border_lines, middle_line)
  -- end

  -- table.insert(border_lines, bottom_border)
  -- api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

  -- local border_win = api.nvim_open_win(border_buf, true, border_opts)

  win = api.nvim_open_win(buf, true, opts)
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

  api.nvim_win_set_option(win, 'cursorline', true)

  api.nvim_buf_set_lines(buf, 0, -1, false, { windowHelper.center('Git helper'), '', ''})
  api.nvim_buf_add_highlight(buf, -1, 'WhidHeader', 0, 0, -1)
end

local function update_view(direction)
  local width = api.nvim_win_get_width(0)

  local height = api.nvim_win_get_height(0)

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)
  api.nvim_buf_set_option(buf, 'modifiable', true)


  local result = {}

  local unstagedFile = api.nvim_call_function('systemlist', {
      'git diff --name-status'
    })
  table.insert(result, border.fn.topBorderText("Unstaged", currentBorder, win_width))
  for k,v in pairs(unstagedFile) do
    table.insert(result, border.fn.middleBorderText(unstagedFile[k], currentBorder, win_width))
  end

  local untrakedFile = api.nvim_call_function('systemlist', {
      'git ls-files --others'
  })

  for k,v in pairs(untrakedFile) do
    table.insert(result, border.fn.middleBorderText("A    ".. untrakedFile[k], currentBorder, win_width))
  end

  table.insert(result, border.fn.bottomBorder(currentBorder, win_width))

  local stagedFile = api.nvim_call_function('systemlist', {
      'git diff --name-status --cached'
    })

  table.insert(result, border.fn.topBorderText("Staged", currentBorder, win_width))
  for k,v in pairs(stagedFile) do
    table.insert(result, border.fn.middleBorderText(stagedFile[k], currentBorder, win_width))
  end

  table.insert(result, border.fn.bottomBorder(currentBorder, win_width))

  local completStatus = api.nvim_call_function('systemlist', {
      'git status'
    })
  table.insert(result, border.fn.topBorderText("Complet status", currentBorder, win_width))
  for k,v in pairs(completStatus) do
    table.insert(result, border.fn.middleBorderText(completStatus[k], currentBorder, win_width))
  end
  table.insert(result, border.fn.bottomBorder(currentBorder, win_width))

  api.nvim_buf_set_lines(buf, 1, 2, false, {"s = Stage file, u = unstage file, d = Discrard file, c = Commit, p = push, t = test"})

  api.nvim_buf_set_lines(buf, 2, -1, false, result)

  api.nvim_buf_add_highlight(buf, -1, 'whidSubHeader', 1, 0, -1)
  api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function close_window()
  api.nvim_win_close(win, true)
end

local function test()
  local stringTest = "| m lua/test/border.lua         |"
  stringTest = stringTest:gsub(currentBorder[border.SIDE], "")
  print("stringTest1 : ")
  print(stringTest)
  stringTest = stringTest:match("^%s*(.-)%s*$")
  print("stringTest2 : ")
  print(stringTest)
   local path = stringTest:match("%s*%a+%s+(.+)")
  print('Test2 : ' .. path)
end

local function getFilePathFromGitstatus(gitStatus)
  gitStatus = gitStatus:gsub(currentBorder[border.SIDE], "")
  gitStatus = gitStatus:match("^%s*(.-)%s*$")
  local path = gitStatus:match("%s*%a+%s+(.+)")
  return path
end

local function open_file()
  close_window()
  api.nvim_command('edit '..getFilePathFromGitstatus(api.nvim_get_current_line()))
end

local function stage_file()
  local path = getFilePathFromGitstatus(api.nvim_get_current_line())
  local command = "git add " .. path
  print('test'..command.. "test")
  vim.fn.system(command)
  update_view(0)
end

local function unstage_file()
  local path = getFilePathFromGitstatus(api.nvim_get_current_line())
  local command = "git restore --staged " .. path
  vim.fn.system(command)
  update_view(0)
end

local function discard_file()
  local path = getFilePathFromGitstatus(api.nvim_get_current_line())
  local command = "git restore " .. path
  vim.fn.system(command)
  update_view(0)
end

local function git_push()
  local command = "git push"
  vim.fn.system(command)
  update_view(0)
end

local function commit()
  local commitBuf = api.nvim_create_buf(false, true)
  
  -- Set the buffer to unmodified to avoid the E5108 error
  api.nvim_buf_set_option(commitBuf, 'modifiable', false)

  -- Open a new window for the terminal buffer
  local opts = {
    style = "minimal",
    relative = "editor",
    width = 80,
    height = 20,
    row = 10,
    col = 10,
    border = "rounded"
  }
  local win = api.nvim_open_win(commitBuf, true, opts)

  -- Run the git commit command in the terminal buffer
  vim.fn.termopen("git commit", {
    on_exit = function(_, exit_code, _)
      if exit_code == 0 then
        print("Commit successful")
      else
        print("Commit failed")
      end
      -- Close the window and buffer
      api.nvim_win_close(win, true)
      api.nvim_buf_delete(commitBuf, { force = true })
      update_view(0)
    end
  })
end

local function set_mappings()
  local mappings = {
    ['<cr>'] = 'open_file()',
    q = 'close_window()',
    s = 'stage_file()',
    u = 'unstage_file()',
    d = 'discard_file()',
    c = 'commit()',
    p = 'git_push()',
    t = 'test()',
  }

  for k,v in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"githelper.window".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end

  -- Disable key while using the plugin
  local other_chars = {
    'a', 'b', 'e', 'f', 'g', 'i', 'n', 'o', 'r', 'v', 'w', 'x', 'y', 'z'
  }

  for k,v in ipairs(other_chars) do
    api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n',  '<c-'..v..'>', '', { nowait = true, noremap = true, silent = true })
  end

end

local function contentOption(opts, key)
  if opts[key] and opts[key] == true then
    api.nvim_buf_set_option(buf, key, false)
  end
end

local function generateContent(content, opts)
-- content is array
  api.nvim_buf_set_lines(buf, 1, 2, false, {windowHelper.center('HEAD~'..position)})
  api.nvim_buf_set_lines(buf, 2, 3, false, {"testing"})

  api.nvim_buf_set_lines(buf, 4, -1, false, result)

  api.nvim_buf_add_highlight(buf, -1, 'whidSubHeader', 1, 0, -1)
  contentOption(opts, "modifiable")

end


local function window(content, opts)
  position = 0
  open_window()
  set_mappings()
  update_view(0)
  api.nvim_win_set_cursor(win, {4, 0})
  -- generateContent(content, opts)
end

return {
  window = window,
  update_view = update_view,
  open_file = open_file,
  stage_file = stage_file,
  unstage_file = unstage_file,
  discard_file = discard_file,
  commit = commit,
  git_push = git_push,
  test = test,
  close_window = close_window
}
