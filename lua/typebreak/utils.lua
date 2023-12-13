local M = {}

M.table_sum = function(table)
	local sum = 0
	for _, v in pairs(table) do
		sum = sum + v
	end
	return sum
end

M.center_text = function(text, width)
	return string.rep(" ", width / 2 - string.len(text) / 2) .. text
end

local ns = vim.api.nvim_create_namespace("typebreak")

M.highlight_text = function(row, col_start, col_end)
	vim.api.nvim_buf_set_extmark(0, ns, row, col_start, {
		hl_group = "ErrorMsg",
		end_row = row,
		end_col = col_end,
	})
end

M.reset_highlights = function()
	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

M.extend_table = function(a, b)
	for _, v in ipairs(b) do
		table.insert(a, v)
	end
	return a
end

return M
