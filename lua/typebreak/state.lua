local utils = require("typebreak.utils")

local data_path = vim.fn.stdpath("data")
local storage_path = vim.fs.joinpath(data_path, "typebreak.json")

local M = {
    previous_times = {}
}

M.last_time = function()
    return M.previous_times[#M.previous_times]
end

M.average_time = function(current_time)
    local total = utils.table_sum(M.previous_times)
    local count = #M.previous_times

    if current_time ~= nil then
        total = total + current_time
        count = count + 1
    end

    if count == 0 then
        return nil
    end

    return total / count
end

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


return M
