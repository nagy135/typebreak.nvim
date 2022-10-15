local Path = require('plenary.path')
local utils = require('typebreak.utils')

local data_path = vim.fn.stdpath("data")
local storage_path = string.format("%s/typebreak.json", data_path)

local M = {
    previous_times = {}
}


M.load = function()
    local path = Path:new(storage_path)
    local ok, storage = pcall(read, path)
    if not ok then
        return
    end
    local ok2, result = pcall(vim.fn.json_decode, storage)
    if ok2 then
        M.previous_times = result
    end
end

M.record = function(time)
    table.insert(M.previous_times, time)
    Path:new(storage_path):write(vim.fn.json_encode(M.previous_times), "w")
end

M.repr = function()
    local last = M.previous_times[1] or "N/A"
    local avg = (utils.table_sum(M.previous_times) / #M.previous_times) or "N/A"
    return "Last: " .. last .. ', Avg: ' .. avg
end


return M
