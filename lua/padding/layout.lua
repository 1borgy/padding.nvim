local Window = require("padding.window")
local Config = require("padding.config")

local Layout = {}

function Layout.resize()
	local available_width = vim.api.nvim_list_uis()[1].width

	-- TODO: make this configurable ish
	local viewport_width = #Window.get_user_windows() * Config.opts.viewport.width

	local available_padding = available_width - viewport_width - 2
	local left_padding = available_padding / 2 + (available_padding % 2) / 2
	local right_padding = available_padding - left_padding

	vim.api.nvim_echo(
		{ { "Resizing padding to: { left=" .. left_padding .. ", right=" .. right_padding .. " }" } },
		true,
		{}
	)

	Window.set_padding({ left = left_padding, right = right_padding })
end

return Layout
