local M = {}

local api = vim.api
local curl = require("plenary.curl")
local state = require("typebreak.state")
local dictionary = require("typebreak.dictionary")

local utils = require("typebreak.utils")

local N_WORDS = 10

local reset_state = function()
	M.round_done = false
	M.buf = nil
	M.memory = ""
	M.words = {}
	M.found = 0
	M.lines = {}
	M.highlight_starts = {}
	M.ignore_lines = {}
	M.width = 50
	M.height = N_WORDS
	M.timestamp = nil
	M.end_time = nil
end

local local_dictionary = false

reset_state()

function M.start(use_local_dictionary)
	local_dictionary = use_local_dictionary or false
	reset_state()

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
		border = "rounded",
		anchor = "NW",
		style = "minimal",
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
	M.highlight_starts = {}
	M.offsets = {}
	M.memory = ""

	if local_dictionary then
		M.words = dictionary.pick_random_words(N_WORDS)
	else
		local response = curl.get("https://random-word-api.herokuapp.com/word?number=" .. N_WORDS)
		if response == nil then
			print("could not fetch words from herokuapp.com")
			return
		end
		local body = response.body
		local delimiter = ","
		for match in (body .. delimiter):gmatch("(.-)" .. delimiter) do
			match = string.gsub(match, "%W", "")
			table.insert(M.words, match)
			table.insert(M.highlight_starts, false)
		end
	end

	for _, word in pairs(M.words) do
		local length = string.len(word)
		local before = math.random(0, M.width - length)
		local after = M.width - length - before
		table.insert(M.lines, string.rep(" ", before) .. word .. string.rep(" ", after))
		table.insert(M.offsets, before)
	end
end

function M.reset_redraw_stats()
	state.reset()
	api.nvim_buf_set_lines(M.buf, 6, 7, false, {
		utils.center_text(state.repr(M.end_time), M.width),
	})
end

function M.draw()
	api.nvim_buf_set_lines(M.buf, 0, N_WORDS, false, M.lines)
	for k, match_len in pairs(M.highlight_starts) do
		if match_len ~= false then
			utils.highlight_text(k - 1, M.offsets[k], M.offsets[k] + match_len)
		end
	end
end

-- TODO: generalize this using table and loop
function M.set_summary(title_text, time_text, stats_text)
	M.lines = {
		"",
		"",
		utils.center_text(title_text, M.width),
		"",
		stats_text ~= nil and utils.center_text(time_text, M.width) or "",
		"",
		stats_text ~= nil and utils.center_text(stats_text, M.width) or "",
		utils.center_text("to reset press `r`", M.width),
		"",
		"",
	}
	M.draw()
end

function M.key_pressed(key)
	if key == "<BS>" then -- BACKSPACE
		M.memory = string.sub(M.memory, 0, -2)
		key = ""
	elseif key == "<CR>" then -- RESET
		if not M.round_done then
			return
		end
		api.nvim_buf_set_lines(M.buf, 0, N_WORDS, false, M.lines)

		M.found = 0
		M.fetch_new_lines()
		M.round_done = false
		M.timestamp = os.time()
		M.draw()
		return
	end

	if M.round_done then
		if key == "r" then
			M.reset_redraw_stats()
		end
		return
	end

	M.memory = M.memory .. key

	-- reset highlights
	for k, _ in pairs(M.highlight_starts) do
		M.highlight_starts[k] = false
	end
	utils.reset_highlights()

	local match = false
	for k, word in pairs(M.words) do
		if M.ignore_lines[k] == nil then
			if string.sub(M.memory, -string.len(word)) == word then
				match = true
				table.insert(M.ignore_lines, k, true)
				M.found = M.found + 1
				M.lines[k] = string.rep(" ", M.width)
			else
				-- NOTE: we iterate to find smaller match
				for x = string.len(word), 1, -1 do
					local part = string.sub(word, 0, x)
					local part_len = string.len(part)
					if string.sub(M.memory, -part_len) == part then
						M.highlight_starts[k] = part_len
						break
					end
				end
			end
		end
	end
	if match == true then
		for hk, _ in pairs(M.highlight_starts) do
			print("resetting highlights", hk)
			M.highlight_starts[hk] = false
		end
		M.memory = ""
	end
	M.draw()

	if M.found == M.height then
		M.end_time = os.time() - M.timestamp
		M.set_summary(
			string.format("Done in : %d seconds", M.end_time),
			"To refresh press <CR> (Enter)",
			state.repr(M.end_time)
		)
		M.round_done = true
		state.record(M.end_time)
	end
end

function M.set_mapping()
	local keys = {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z",
		"<BS>",
		"<CR>",
	}
	for _, letter in pairs(keys) do
		vim.keymap.set("i", letter, function()
			M.key_pressed(letter)
		end, {
			buffer = 0,
		})
	end
end

function M.setup(options)
	local opts = options or {}

	if opts.dictionary ~= nil then
		local replace = opts.replace_dictionary or false
		dictionary.extend_or_replace_dictionary(opts.dictionary, replace)
	end
end

return M
