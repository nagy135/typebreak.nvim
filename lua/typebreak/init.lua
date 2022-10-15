local M = {}

local api = vim.api
local curl = require("plenary.curl")
local state = require('typebreak.state')

M.buf = nil
M.memory = ""
M.words = {}
M.found = 0
M.lines = {}
M.width = 50
M.height = 10
M.timestamp = nil

function M.start()
    local ui = api.nvim_list_uis()[1]

    state.load()

    M.fetch_new_lines()

    M.buf = api.nvim_create_buf(false, true)

    M.draw()

    local opts = {
        relative = "editor",
        width = M.width,
        height = M.height,
        col = (ui.width / 2) - (M.width / 2),
        row = (ui.height / 2) - (M.height / 2),
        border = "shadow",
        anchor = 'NW',
        style = 'minimal',
    }

    api.nvim_open_win(M.buf, true, opts)

    M.set_mapping()
    M.timestamp = os.time()
    vim.cmd("startinsert")
end

function M.fetch_new_lines()
    -- reset
    M.lines = {}
    M.words = {}
    M.memory = ""

    local response = curl.get("https://random-word-api.herokuapp.com/word?number=10")
    if response == nil then
        print('could not fetch words from herokuapp.com')
        return
    end
    local body = response.body

    local delimiter = ","
    for match in (body .. delimiter):gmatch("(.-)" .. delimiter) do
        match = string.gsub(match, '%W', '')
        table.insert(M.words, match)
    end

    for _, word in pairs(M.words) do
        local length = string.len(word)
        local before = math.random(0, M.width - length)
        local after = M.width - length - before
        table.insert(M.lines, string.rep(' ', before) .. word .. string.rep(' ', after))
    end

end

function M.draw()
    api.nvim_buf_set_lines(M.buf, 0, 10, false, M.lines)
end

-- TODO: generalize this using table and loop
function M.set_centered_text(title_text, time_text, stats_text)
    local spacer1 = string.rep(' ', M.width / 2 - string.len(title_text) / 2)
    local title_text_final = spacer1 .. title_text

    local time_text_final = ""
    if time_text ~= nil then
        local spacer2 = string.rep(' ', M.width / 2 - string.len(time_text) / 2)
        time_text_final = spacer2 .. time_text
    end

    local stats_text_final = ""
    if stats_text ~= nil then
        local spacer3 = string.rep(' ', M.width / 2 - string.len(stats_text) / 2)
        stats_text_final = spacer3 .. stats_text
    end

    M.lines = {
        "",
        "",
        "",
        title_text_final,
        "",
        time_text_final,
        "",
        stats_text_final,
        "",
        ""
    }

    M.draw()
end

function M.key_pressed(key)
    if key == "<BS>" then -- BACKSPACE
        M.memory = string.sub(M.memory, 0, -2)
        M.draw()
        return
    elseif key == "<CR>" then -- RESET
        api.nvim_buf_set_lines(M.buf, 0, 10, false, M.lines)
        M.timestamp = os.time()

        M.found = 0
        M.fetch_new_lines()
        M.draw()
        return
    end

    M.memory = M.memory .. key
    local match = false
    for k, word in pairs(M.words) do
        if string.sub(M.memory, -string.len(word)) == word then
            match = true
            M.found = M.found + 1
            M.lines[k] = string.rep(' ', M.width)
        end
    end
    if match == true then
        M.memory = ""
        M.draw()
    end

    if M.found == M.height then
        local time_taken = os.time() - M.timestamp
        M.set_centered_text(
            string.format("Done in : %d", time_taken),
            "To refresh press <CR> (Enter)",
            state.repr()
        )
        state.record(time_taken)
    end
end

function M.set_mapping()
    local keys = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
        "u", "v", "w", "x", "y", "z", "<BS>", "<CR>" }
    for _, letter in pairs(keys) do
        vim.keymap.set("i", letter, function() M.key_pressed(letter) end, {
            buffer = 0
        })
    end
end

return M
