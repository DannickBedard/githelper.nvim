local M = {}

local border = require("githelper.border")

function M.setup(opts)
  opts = opts or {}

  local keymap = opts.keymap
  local currentBorder = opts.border
  if not keymap then
    keymap = "<leader>t"
  end

  if not currentBorder then
    currentBorder = border.simpleBorder
  end

  vim.keymap.set("n", keymap, function()
    local Window = require("githelper.windowClass")

    Window:new(currentBorder)
    Window:open()

    if vim.fn.has("nvim-0.7.0") ~= 1 then
      vim.api.nvim_err_writeln("Example.nvim requires at least nvim-0.7.0.")
      return;
    end
  end
  )
end

return M
