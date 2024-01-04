local Config = {}

---@class PaddingOptions
local defaults = {
	padding = {
		win_opts = {
			cursorline = false,
			number = false,
			relativenumber = false,
		},
		buf_opts = {
			buftype = "nofile",
			filetype = "padding",
			buflisted = false,
		},
		prevent_focus = true,
		min_width = {
			left = 5,
			right = 5,
		},
	},
	viewport = {
		width = 110,
	},
	ignore_filetypes = {},
}

---@type PaddingOptions
Config.opts = {}
---@return PaddingOptions

function Config.setup(opts)
	Config.opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return Config
