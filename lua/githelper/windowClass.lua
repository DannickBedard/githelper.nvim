local api = vim.api
local buf, win

local border = require("githelper.border")

-- Meta class
Window = { currentBorder = border.simpleBorder, gitKeymap}

local windowHelper = require("githelper.windowHelper")
local gitUtils = require("githelper.gitUtils")

function Window:new(currentBorder, gitKeymap)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.currentBorder = currentBorder or border.simpleBorder
  self.gitKeymap = gitKeymap or {}
  return o
end

function Window:getBorder()
  return self.currentBorder
end

function Window:open()
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
    relative = "editor",
    width = win_width ,
    height = math.ceil(win_height),
    row = row,
    col = col,
    border = 'single'
  }

  win = api.nvim_open_win(buf, true, opts)
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

  api.nvim_win_set_option(win, 'cursorline', true)

  api.nvim_buf_set_lines(buf, 0, -1, false, { windowHelper.center('Git helper'), '', ''})
  api.nvim_buf_add_highlight(buf, -1, 'WhidHeader', 0, 0, -1)

  Window:set_mappings()
  Window:update_view()
  api.nvim_win_set_cursor(win, {4, 0})
end

function Window:update_view()
  local width = api.nvim_win_get_width(0)

  local height = api.nvim_win_get_height(0)

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)
  api.nvim_buf_set_option(buf, 'modifiable', true)

  local result = {}

  -- Unstaged File
  local unstagedFile = gitUtils.getUnstagedFile()
  table.insert(result, border.fn.topBorderText("Unstaged", self.currentBorder, win_width))
  for k,v in pairs(unstagedFile) do
    table.insert(result, border.fn.middleBorderText(unstagedFile[k], self.currentBorder, win_width))
  end

  local untrakedFile = gitUtils.getUntrakedFile()
  for k,v in pairs(untrakedFile) do
    table.insert(result, border.fn.middleBorderText("A    ".. untrakedFile[k], self.currentBorder, win_width))
  end

  table.insert(result, border.fn.bottomBorder(self.currentBorder, win_width))

  -- Stage file
  local stagedFile = gitUtils.getStagedFile()
  table.insert(result, border.fn.topBorderText("Staged", self.currentBorder, win_width))
  for k,v in pairs(stagedFile) do
    table.insert(result, border.fn.middleBorderText(stagedFile[k], self.currentBorder, win_width))
  end

  table.insert(result, border.fn.bottomBorder(self.currentBorder, win_width))

  -- Status
  local completStatus = gitUtils.getStatus()
  table.insert(result, border.fn.topBorderText("Complet status", self.currentBorder, win_width))
  for k,v in pairs(completStatus) do
    table.insert(result, border.fn.middleBorderText(completStatus[k], self.currentBorder, win_width))
  end

  table.insert(result, border.fn.bottomBorder(self.currentBorder, win_width))

  -- Tips
  api.nvim_buf_set_lines(buf, 1, 2, false, {"s = Stage file, u = unstage file, d = Discrard file, c = Commit, p = push, pl = pull, <cr> = edit file"})

  -- Tables of content
  api.nvim_buf_set_lines(buf, 2, -1, false, result)

  api.nvim_buf_add_highlight(buf, -1, 'whidSubHeader', 1, 0, -1)
  api.nvim_buf_set_option(buf, 'modifiable', false)
end

function Window:close_window()
  api.nvim_win_close(win, true)
end

local function getFilePathFromGitstatus()
  local gitStatus = api.nvim_get_current_line()
  local currentBorder = Window:getBorder()
  gitStatus = gitStatus:gsub(currentBorder[border.SIDE], "")
  gitStatus = gitStatus:match("^%s*(.-)%s*$")
  local path = gitStatus:match("%s*%a+%s+(.+)")
  return path
end

local function open_file()
  local currentFile = getFilePathFromGitstatus()
  Window:close_window()
  api.nvim_command('edit '.. currentFile)
end

local function stage_file()
  gitUtils.actions.stageFile(getFilePathFromGitstatus())
  Window:update_view()
end

local function unstage_file()
  gitUtils.actions.unstageFile(getFilePathFromGitstatus())
  Window:update_view()
end

local function discard_file()
  local filePath = getFilePathFromGitstatus()
  gitUtils.actions.discardFile(filePath)
  gitUtils.actions.discardUntrakedFile(filePath)
  Window:update_view()
end

local function git_push()
  gitUtils.actions.push()
  Window:update_view()
end

local function git_pull()
  gitUtils.actions.pull()
  Window:update_view()
end

local function git_diff()
  local filePath = getFilePathFromGitstatus()
  gitUtils.actions.diff(Window, filePath)
end


local function commit()
  gitUtils.actions.commit(Window)
end

function Window:set_mappings()
  local defaultGitKeymap = {
    quit = "q",
    edit = "<cr>",
    stage = "s",
    unstage = "u",
    discard = "d",
    commit = "c",
    push = "p",
    pull = "pl",
    diff = "gd",
  }

  local mappings = {
    [self.gitKeymap.edit or defaultGitKeymap.edit] = function ()
     open_file()
    end,
    [self.gitKeymap.quit or defaultGitKeymap.quit] = function ()
      Window:close_window()
    end ,
    [self.gitKeymap.stage or defaultGitKeymap.stage] = function ()
      stage_file()
    end,
    [self.gitKeymap.unstage or defaultGitKeymap.unstage] = function ()
      unstage_file()
    end,
    [self.gitKeymap.discard or defaultGitKeymap.discard] = function ()
      discard_file()
    end,
    [self.gitKeymap.commit or defaultGitKeymap.commit] = function ()
      commit()
    end,
    [self.gitKeymap.push or defaultGitKeymap.push] = function ()
      git_push()
    end,
    [self.gitKeymap.pull or defaultGitKeymap.pull] = function ()
      print("pulling")
      git_pull()
    end,
    [self.gitKeymap.diff or defaultGitKeymap.diff] = function ()
      git_diff()
    end
  }

  for k,v in pairs(mappings) do
    vim.keymap.set("n", k, function()
      -- api.nvim_buf_set_keymap(buf, 'n', k, function ()
      v()
    end, {
        buffer = buf, nowait = true, noremap = true, silent = true
      })
  end

  -- Disable key while using the plugin
  local other_chars = {
    't','a', 'b', 'e', 'f', 'i', 'n', 'o', 'r', 'v', 'w', 'x', 'y', 'z'
  }

  for k,v in ipairs(other_chars) do
    api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(buf, 'n',  '<c-'..v..'>', '', { nowait = true, noremap = true, silent = true })
  end

end

local function window(content, opts)
  Window:open_window()
  Window:update_view()
  api.nvim_win_set_cursor(win, {4, 0})
end

return Window
