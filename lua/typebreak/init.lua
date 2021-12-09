local M = {}

local api = vim.api

function M.start()
    local width = 50
    local height = 10
    local ui = api.nvim_list_uis()[1]

    local words = {
        "haha",
        "haha"
    }

    for item in pairs(words) do
        print("item", item);
    end

    local buf = api.nvim_create_buf(false, 0)

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = (ui.width/2) - (width/2),
        row = (ui.height/2) - (height/2),
        border = "shadow",
        anchor = 'NW',
        style = 'minimal',
    }
    local win = api.nvim_open_win(buf, 1, opts)
end


M.start()

return M
