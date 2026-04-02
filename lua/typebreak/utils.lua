local M = {}

M.table_sum = function(table)
	local sum = 0
	for _, v in pairs(table) do
		sum = sum + v
	end
	return sum
end

M.center_text = function(text, width)
	local padding = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
	return string.rep(" ", padding) .. text
end

local ns = vim.api.nvim_create_namespace("typebreak")

M.highlight_text = function(buf, row, col_start, col_end)
	vim.api.nvim_buf_set_extmark(buf, ns, row, col_start, {
		hl_group = "ErrorMsg",
		end_row = row,
		end_col = col_end,
	})
end

M.clear_highlights = function(buf)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

M.reset_highlights = M.clear_highlights

M.extend_table = function(a, b)
	for _, v in ipairs(b) do
		table.insert(a, v)
	end
	return a
end

return M
