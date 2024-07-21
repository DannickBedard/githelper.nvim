local M = {}

function M.setup(opts)
  opts = opts or {}

  local keymap = opts.keymap
  if not keymap then
    keymap = "<leader>t"
  end

  vim.keymap.set("n", keymap, function()
    local windowManager = require("githelper.window")
    windowManager.window()

    if vim.fn.has("nvim-0.7.0") ~= 1 then
      vim.api.nvim_err_writeln("Example.nvim requires at least nvim-0.7.0.")
      return;
    end
  end
  )
end

return M
