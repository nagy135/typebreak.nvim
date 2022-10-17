local M = {}

M.table_sum = function(table)
    local sum = 0
    for _, v in pairs(table) do
        sum = sum + v
    end
    return sum
end
local tmpnamespace = vim.api.nvim_create_namespace('typebreak')

M.highlight_text = function(row, col_start, col_end)
    vim.api.nvim_buf_set_extmark(
        0,
        tmpnamespace,
        row,
        col_start,
        {
            hl_group = 'ErrorMsg',
            end_row = row,
            end_col = col_end
        }
    )
end

M.reset_highlights = function()
    vim.api.nvim_buf_clear_namespace(
        0,
        tmpnamespace,
        0,
        -1
    )
end

return M
