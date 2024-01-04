local Config = require("padding.config")

local Window = {}

Window.pad_windows = {
	left = nil,
	right = nil,
}

function Window.is_padding_window(window)
	for _, pad_window in pairs(Window.pad_windows) do
		if window == pad_window then
			return true
		end
	end

	return false
end

local function is_user_window(window)
	-- Not a user window if it's a padding window
	if Window.is_padding_window(window) then
		return false
	end

	-- Not a user window if it's a floating window (has zindex)
	local window_config = vim.api.nvim_win_get_config(window)
	if window_config.zindex then
		return false
	end

	-- Not a user window if it's in the list of ignored filetypes
	local bufnr = vim.api.nvim_win_get_buf(window)
	for _, ignored_filetype in ipairs(Config.opts.ignore_filetypes) do
		if vim.bo[bufnr].filetype == ignored_filetype then
			return false
		end
	end

	return true
end

function Window.get_user_windows()
	local user_windows = {}

	for _, window in ipairs(vim.api.nvim_list_wins()) do
		if is_user_window(window) then
			table.insert(user_windows, window)
		end
	end

	return user_windows
end

local function get_leftmost_and_rightmost_windows()
	-- todo fix all of this
	local leftmost_window = nil
	local rightmost_window = nil

	-- lol
	local leftmost_col = 9999999999
	local rightmost_col = -1

	for _, window in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(window)
		local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
		local relative = vim.api.nvim_win_get_config(window).relative

		if (buftype == "" or buftype == "terminal") and relative == "" then
			local window_position = vim.api.nvim_win_get_position(window)
			local col = window_position[2]

			if col < leftmost_col then
				leftmost_window = window
				leftmost_col = col
			end

			if col > rightmost_col then
				rightmost_window = window
				rightmost_col = col
			end
		end
	end

	return leftmost_window, rightmost_window
end

local function create_pad_window(starting_window, create_cmd)
	-- Enter the leftmost or rightmost window before running the split commands
	if starting_window and vim.api.nvim_win_is_valid(starting_window) then
		vim.api.nvim_set_current_win(starting_window)
	end

	vim.cmd(create_cmd)

	local pad_win = vim.api.nvim_get_current_win()
	local pad_buf = vim.api.nvim_win_get_buf(pad_win)

	-- Set win/buf options from config
	for opt, value in pairs(Config.opts.padding.win_opts) do
		vim.opt[opt] = value
	end

	for opt, value in pairs(Config.opts.padding.buf_opts) do
		vim.bo[pad_buf][opt] = value
	end

	return pad_win
end

local function show_left_padding_window()
	if Window.pad_windows.left == nil then
		-- Find leftmost window before running ``leftabove vnew``
		local leftmost_col = nil
		local leftmost_window = nil

		-- TODO: consolidate this logic elsewhere
		for _, window in ipairs(Window.get_user_windows()) do
			local _, col = vim.api.nvim_win_get_position(window)
			if leftmost_col == nil or col < leftmost_col then
				leftmost_col = col
				leftmost_window = window
			end
		end
		Window.pad_windows.left = create_pad_window(leftmost_window, "leftabove vnew")
	end
end

local function show_right_padding_window()
	if Window.pad_windows.right == nil then
		-- Find rightmost window before running ``vnew``
		local rightmost_col = nil
		local rightmost_window = nil

		for _, window in ipairs(Window.get_user_windows()) do
			local _, col = vim.api.nvim_win_get_position(window)
			if rightmost_col == nil or col > rightmost_col then
				rightmost_col = col
				rightmost_window = window
			end
		end

		Window.pad_windows.right = create_pad_window(rightmost_window, "vnew")
	end
end

local function hide_left_padding_window()
	if Window.pad_windows.left ~= nil then
		vim.api.nvim_win_close(Window.pad_windows.left, true)
		Window.pad_windows.left = nil
	end
end

local function hide_right_padding_window()
	if Window.pad_windows.right ~= nil then
		vim.api.nvim_win_close(Window.pad_windows.right, true)
		Window.pad_windows.right = nil
	end
end

local function create_padding_windows()
	show_left_padding_window()
	show_right_padding_window()
end

function Window.enable()
	local focused_window = vim.api.nvim_get_current_win()

	create_padding_windows()

	-- Reset focus to the window that was open previously
	vim.api.nvim_set_current_win(focused_window)
end

function Window.disable()
	for pad_window_key, pad_window in pairs(Window.pad_windows) do
		if vim.api.nvim_win_is_valid(pad_window) then
			vim.api.nvim_win_close(pad_window, true)
			Window.pad_windows[pad_window_key] = nil
		end
	end
end

function Window.set_padding(widths)
	if widths.left < Config.opts.padding.min_width.left then
		hide_left_padding_window()
	else
		show_left_padding_window()
		vim.api.nvim_win_set_width(Window.pad_windows.left, widths.left)
	end

	if widths.right < Config.opts.padding.min_width.right then
		hide_right_padding_window()
	else
		show_right_padding_window()
		vim.api.nvim_win_set_width(Window.pad_windows.right, widths.right)
	end
end

return Window
