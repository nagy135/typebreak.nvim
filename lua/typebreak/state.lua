local utils = require("typebreak.utils")

local data_path = vim.fn.stdpath("data")
local storage_path = vim.fs.joinpath(data_path, "typebreak.json")

local M = {
    previous_times = {}
}

local load_json_from_path = function(path)
    local lines = vim.fn.readfile(path)
    if #lines == 0 then
        return {}
    end

    return vim.json.decode(table.concat(lines, "\n"))
end

local store_state = function()
    vim.fn.writefile({ vim.json.encode(M.previous_times) }, storage_path)
end

M.load = function()
    local ok, result = pcall(load_json_from_path, storage_path)
    if ok and type(result) == "table" then
        M.previous_times = result
    end
end

M.record = function(time)
    table.insert(M.previous_times, time)
    store_state()
end

M.reset = function()
    M.previous_times = {}
    store_state()
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
