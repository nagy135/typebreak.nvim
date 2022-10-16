local M = {}

M.table_sum = function(table)
    local sum = 0
    for _, v in pairs(table) do
        sum = sum + v
    end
    return sum
end

return M
