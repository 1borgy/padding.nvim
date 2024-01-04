local Config = require("padding.config")
local Layout = require("padding.layout")
local Window = require("padding.window")

local Autocmds = {}

local autocmd_group_name = "padding"

local previous_window = nil

local function on_win_leave()
	-- Keep track of the last "valid" window we were in
	local leaving_from_window = vim.api.nvim_get_current_win()

	if not Window.is_padding_window(leaving_from_window) then
		previous_window = leaving_from_window
	end
end

local function find_focusable_window()
	-- Check the previous valid window we were in
	if previous_window ~= nil and vim.api.nvim_win_is_valid(previous_window) then
		return previous_window
	end

	-- In the case the previous window is not valid, find any window that is not a
	-- padding window
	for _, window in ipairs(vim.api.nvim_list_wins()) do
		if not Window.is_padding_window(window) then
			return window
		end
	end
end

local function on_win_enter()
	local entered_window = vim.api.nvim_get_current_win()

	-- If entering a padding window, set back to the last valid window
	if Window.is_padding_window(entered_window) then
		vim.api.nvim_set_current_win(find_focusable_window())
	end
end

local function on_quit_pre()
	local num_user_windows = #Window.get_user_windows()

	if num_user_windows == 1 then
		Window.disable()
	end
end

function Autocmds.enable()
	vim.api.nvim_create_augroup(autocmd_group_name, { clear = true })

	vim.api.nvim_create_autocmd({ "VimResized" }, {
		callback = function()
			Layout.resize()
		end,
		group = autocmd_group_name,
	})

	vim.api.nvim_create_autocmd({ "WinNew" }, {
		callback = function()
			Layout.resize()
		end,
		group = autocmd_group_name,
	})

	if Config.opts.padding.prevent_focus then
		vim.api.nvim_create_autocmd({ "WinEnter" }, {
			callback = function()
				on_win_enter()
			end,
			group = autocmd_group_name,
		})

		vim.api.nvim_create_autocmd({ "WinLeave" }, {
			callback = function()
				on_win_leave()
			end,
			group = autocmd_group_name,
		})
	end

	vim.api.nvim_create_autocmd({ "QuitPre" }, {
		callback = function()
			on_quit_pre()
		end,
		group = autocmd_group_name,
	})

	-- vim.api.nvim_create_autocmd({ "WinClosed" }, {
	-- 	callback = function()
	-- 		Layout.resize()
	-- 	end,
	-- 	group = autocmd_group_name,
	-- })
end

function Autocmds.disable()
	vim.api.nvim_del_augroup_by_name(autocmd_group_name)
end

return Autocmds
