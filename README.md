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
        require("githelper").setup({
            keymap = "<leader>t",
            border = border.simpleBorder -- doubleBorder, simpleBorder, simpleRoundedBorder, simpleThickBorder
        })
    end
}
```

## Keymaps

s => stage file
u => unstage file
d => discard file
c => commit
p => push
pl => pull
<cr> => edit file

# TODOS : 

- [ ] Enhance the setup
    - [x] Make the keybinding in the setup.
    - [x] Make the window into a class. So i can be more customisable
    - [ ] Make git keymap customisable
- [ ] Make documentation
    - [x] image to show feature
    - [ ] Giph to show feature
    - [x] Doc setup & installation

- [ ] Border
    - [x] Make rouded corder available

