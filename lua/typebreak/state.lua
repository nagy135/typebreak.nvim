local Path = require('plenary.path')
local utils = require('typebreak.utils')

local data_path = vim.fn.stdpath("data")
local storage_path = string.format("%s/typebreak.json", data_path)

local M = {
    previous_times = {}
}


local load_json_from_path = function(path)
    return vim.fn.json_decode(Path:new(path):read())
end

M.load = function()
    local ok, result = pcall(load_json_from_path, storage_path)
    if ok then
        M.previous_times = result
    end
end

M.record = function(time)
    table.insert(M.previous_times, time)
    Path:new(storage_path):write(vim.fn.json_encode(M.previous_times), "w")
end

M.repr = function(time)
    local last = #M.previous_times > 0
        and M.previous_times[#M.previous_times]
        or "N/A"
    local avg = #M.previous_times > 0
        and string.format("%.2f", (
            (time + utils.table_sum(M.previous_times)
                ) / (
                #M.previous_times + 1)
            ))
        or "N/A"
    return "Last: " .. last .. ', Avg: ' .. avg
end


return M
