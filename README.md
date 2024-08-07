# githelper.nvim
Small plugin to help stagins file, unstage, discard, commit and push with git.

## Features in image  :
<img width="1200" alt="Capture d’écran, le 2024-07-19 à 23 33 41" src="https://github.com/user-attachments/assets/4dc8e8e2-85d1-4d33-88c2-a10591cc888b">

Commit : 
<img width="1200" alt="commit" src="https://github.com/user-attachments/assets/fb52fd5e-7a2d-4271-8641-521f2b875874">

## Setup

```lua
{
    "DannickBedard/githelper.nvim",
    config = function ()
        local border = require("githelper.border")

        local gitKeymap = { -- Default keymap
            quit = "q",
            edit = "<cr>",
            stage = "s",
            unstage = "u",
            discard = "d",
            commit = "c",
            push = "p",
            pull = "pl",
        }

        require("githelper").setup({
            border = border.simpleRoundedBorder, -- doubleBorder, simpleBorder, simpleRoundedBorder, simpleThickBorder
            gitKeymap = gitKeymap
        });
    end
}
```

# TODOS : 
- [ ] Diff
    - [x] Make the view
    - [ ] Window won't always open... 
- [ ] Make a confirmation for discarding
    - [ ] Make window
    - [ ] Add settings in setup to disable this feature if you find it annoying
