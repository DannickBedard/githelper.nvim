local api = vim.api

local getUnstagedFile = function ()
  local unstagedFile = api.nvim_call_function('systemlist', {
      'git diff --name-status'
    })
  return unstagedFile
end

local getUntrakedFile = function ()
  local untrakedFile = api.nvim_call_function('systemlist', {
      'git ls-files --others'
  })
  return untrakedFile
end

local getStagedFile = function ()
  local stagedFile = api.nvim_call_function('systemlist', {
      'git diff --name-status --cached'
    })
  return stagedFile
end

local getStatus = function ()
  local completStatus = api.nvim_call_function('systemlist', {
      'git status'
    })
  return completStatus
end


return {
  getUnstagedFile = getUnstagedFile,
  getUntrakedFile = getUntrakedFile,
  getStagedFile = getStagedFile,
  getStatus = getStatus
}
