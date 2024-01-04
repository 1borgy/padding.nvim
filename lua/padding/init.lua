local Autocmds = require("padding.autocmds")
local Config = require("padding.config")
local Layout = require("padding.layout")
local Window = require("padding.window")

local Padding = {}

local enabled = false

function Padding.enable()
	Window.enable()
	Layout.resize()
	Autocmds.enable()
end

function Padding.disable()
	Autocmds.disable()
	Window.disable()
end

function Padding.toggle()
	enabled = not enabled

	if enabled then
		Padding.enable()
	else
		Padding.disable()
	end
end

function Padding.setup(opts)
	Config.setup(opts)
end

return Padding
