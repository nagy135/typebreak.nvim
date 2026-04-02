local api = vim.api
local dictionary = require("typebreak.dictionary")
local state = require("typebreak.state")
local utils = require("typebreak.utils")

local M = {}

local N_WORDS = 10
local WIDTH = 50
local REMOTE_WORDS_URL = "https://random-word-api.herokuapp.com/word?number=%d"
local LETTERS = {
	" ",
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
}

local active_session

local function sanitize_word(word)
	return tostring(word):lower():gsub("[^%a]", "")
end

local function session_is_valid(session)
	return session ~= nil
		and session.buf ~= nil
		and session.win ~= nil
		and api.nvim_buf_is_valid(session.buf)
		and api.nvim_win_is_valid(session.win)
end

local function fetch_remote_words()
	if vim.fn.executable("curl") ~= 1 or vim.system == nil then
		return nil
	end

	local result = vim.system({
		"curl",
		"-fsSL",
		string.format(REMOTE_WORDS_URL, N_WORDS),
	}, { text = true }):wait()

	if result.code ~= 0 or result.stdout == nil or result.stdout == "" then
		return nil
	end

	local ok, decoded = pcall(vim.json.decode, result.stdout)
	if not ok or type(decoded) ~= "table" then
		return nil
	end

	local words = {}
	for _, word in ipairs(decoded) do
		local cleaned = sanitize_word(word)
		if cleaned ~= "" then
			table.insert(words, cleaned)
		end
	end

	if #words ~= N_WORDS then
		return nil
	end

	return words
end

local function pick_words(use_local_dictionary)
	if not use_local_dictionary then
		local words = fetch_remote_words()
		if words ~= nil then
			return words
		end
	end

	local words = dictionary.pick_random_words(N_WORDS)
	for i, word in ipairs(words) do
		words[i] = sanitize_word(word)
	end
	return words
end

local function reset_round(session)
	session.round_done = false
	session.memory = ""
	session.words = pick_words(session.use_local_dictionary)
	session.found = 0
	session.lines = {}
	session.highlight_starts = {}
	session.matched = {}
	session.offsets = {}
	session.timestamp = os.time()
	session.end_time = nil

	for index, word in ipairs(session.words) do
		local length = #word
		local before = math.random(0, math.max(0, session.width - length))
		local after = session.width - length - before

		session.lines[index] = string.rep(" ", before) .. word .. string.rep(" ", after)
		session.highlight_starts[index] = false
		session.offsets[index] = before
	end
end

local function draw(session)
	api.nvim_buf_set_lines(session.buf, 0, -1, false, session.lines)
	utils.clear_highlights(session.buf)

	for index, match_length in ipairs(session.highlight_starts) do
		if match_length ~= false then
			utils.highlight_text(session.buf, index - 1, session.offsets[index], session.offsets[index] + match_length)
		end
	end

	api.nvim_win_set_cursor(session.win, { 1, 0 })
end

local function set_summary(session)
	session.lines = {
		"",
		"",
		utils.center_text(string.format("Done in : %d seconds", session.end_time), session.width),
		"",
		utils.center_text("To refresh press <CR> (Enter)", session.width),
		"",
		utils.center_text(state.repr(session.end_time), session.width),
		utils.center_text("to reset press `r`", session.width),
		"",
		"",
	}
	draw(session)
end

local function reset_stats(session)
	state.reset()
	set_summary(session)
end

local function finish_round(session)
	session.end_time = os.time() - session.timestamp
	session.round_done = true
	set_summary(session)
	state.record(session.end_time)
end

local function handle_key(session, key)
	if not session_is_valid(session) then
		return
	end

	if key == "<BS>" then
		session.memory = session.memory:sub(1, -2)
		key = ""
	elseif key == "<CR>" then
		if not session.round_done then
			return
		end

		reset_round(session)
		draw(session)
		vim.cmd.startinsert()
		return
	end

	if session.round_done then
		if key == "r" then
			reset_stats(session)
		end
		return
	end

	session.memory = session.memory .. key
	for index = 1, #session.highlight_starts do
		session.highlight_starts[index] = false
	end

	local found_word = false
	for index, word in ipairs(session.words) do
		if not session.matched[index] then
			if session.memory:sub(-#word) == word then
				session.matched[index] = true
				session.found = session.found + 1
				session.lines[index] = string.rep(" ", session.width)
				found_word = true
			else
				for size = #word, 1, -1 do
					local part = word:sub(1, size)
					if session.memory:sub(-#part) == part then
						session.highlight_starts[index] = #part
						break
					end
				end
			end
		end
	end

	if found_word then
		for index = 1, #session.highlight_starts do
			session.highlight_starts[index] = false
		end
		session.memory = ""
	end

	draw(session)

	if session.found == #session.words then
		finish_round(session)
	end
end

local function close_session(session)
	if active_session == session then
		active_session = nil
	end
	if session ~= nil then
		session.win = nil
		session.buf = nil
	end
end

local function set_mappings(session)
	for _, key in ipairs(LETTERS) do
		vim.keymap.set("i", key, function()
			handle_key(session, key)
		end, {
			buffer = session.buf,
			nowait = true,
			silent = true,
		})
	end

	for _, key in ipairs({ "<BS>", "<CR>" }) do
		vim.keymap.set("i", key, function()
			handle_key(session, key)
		end, {
			buffer = session.buf,
			nowait = true,
			silent = true,
		})
	end

	vim.keymap.set("n", "q", function()
		if session.win ~= nil and api.nvim_win_is_valid(session.win) then
			api.nvim_win_close(session.win, true)
		end
	end, {
		buffer = session.buf,
		nowait = true,
		silent = true,
	})
end

local function open_window(session)
	local ui = session.ui
	local row = math.floor((ui.height - session.height) / 2)
	local col = math.floor((ui.width - session.width) / 2)

	session.buf = api.nvim_create_buf(false, true)
	api.nvim_set_option_value("buftype", "nofile", { buf = session.buf })
	api.nvim_set_option_value("bufhidden", "wipe", { buf = session.buf })
	api.nvim_set_option_value("swapfile", false, { buf = session.buf })
	api.nvim_set_option_value("filetype", "typebreak", { buf = session.buf })

	session.win = api.nvim_open_win(session.buf, true, {
		relative = "editor",
		width = session.width,
		height = session.height,
		col = col,
		row = row,
		border = "rounded",
		anchor = "NW",
		style = "minimal",
	})

	api.nvim_set_option_value("number", false, { win = session.win })
	api.nvim_set_option_value("relativenumber", false, { win = session.win })
	api.nvim_set_option_value("signcolumn", "no", { win = session.win })
	api.nvim_set_option_value("wrap", false, { win = session.win })
	api.nvim_set_option_value("cursorline", false, { win = session.win })

	api.nvim_create_autocmd("BufWipeout", {
		buffer = session.buf,
		once = true,
		callback = function()
			close_session(session)
		end,
	})

	set_mappings(session)
	draw(session)
	vim.cmd.startinsert()
end

function M.start(use_local_dictionary)
	state.load()

	if session_is_valid(active_session) then
		api.nvim_win_close(active_session.win, true)
	end

	local ui = api.nvim_list_uis()[1]
	if ui == nil then
		error("typebreak.nvim requires an attached UI")
	end

	local session = {
		buf = nil,
		win = nil,
		use_local_dictionary = use_local_dictionary or false,
		width = WIDTH,
		height = N_WORDS,
		ui = ui,
	}

	reset_round(session)
	active_session = session
	open_window(session)
end

function M.setup(options)
	local opts = options or {}

	if opts.dictionary ~= nil then
		local replace = opts.replace_dictionary or false
		dictionary.extend_or_replace_dictionary(opts.dictionary, replace)
	end
end

return M
