-- rc.lua
-- Main AwesomeWM orchestration: theme, autostart, rules, plus merging all device + normal keys.

pcall(require, "luarocks.loader") -- If LuaRocks is installed, ensure packages are loaded.

-- Required libraries
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local freedesktop = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
local mytable = awful.util.table or gears.table -- 4.{0,1} compatibility

-- Error handling
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true
		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end

--------------------------------
-- Autostart
--------------------------------

local function runOnce(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end

runOnce({
	"urxvtd",
	"unclutter -root",
	"~/.screenlayout/DefaultLayout.sh",
	"~/.config/awesome/autorun.sh",
})

awful.spawn.with_shell(
	'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;'
		.. 'xrdb -merge <<< "awesome.started:true";'
		.. "dex --environment Awesome --autostart --search-paths "
		.. '"${XDG_CONFIG_HOME:-$HOME/.config}/autostart:${XDG_CONFIG_DIRS:-/etc/xdg}/autostart";'
)

--------------------------------
-- Theme & Layout
--------------------------------

beautiful.init("/home/max/.config/awesome/themes/powerarrow/theme.lua")

--------------------------------
-- Wibar
--------------------------------

local bar = require("bar") -- Adjust if bar.lua is in a subfolder
bar.setupWibar()

--------------------------------
-- Tag Setup
--------------------------------

awful.util.primaryTagnames = { "Entertainment", "Code", "Work", "Obsidian", "Misc" }

-- Layout Mapping Table
layoutMapping = {
	{ func = awful.layout.suit.tile, name = "tile" },
	{ func = awful.layout.suit.tile.left, name = "tileleft" },
	{ func = awful.layout.suit.tile.bottom, name = "tilebottom" },
	{ func = awful.layout.suit.tile.top, name = "tiletop" },
	{ func = awful.layout.suit.fair, name = "fair" },
	{ func = awful.layout.suit.fair.horizontal, name = "fairhorizontal" },
	{ func = awful.layout.suit.spiral, name = "spiral" },
	{ func = awful.layout.suit.dwindle, name = "dwindle" },
	{ func = awful.layout.suit.max, name = "max" },
	{ func = awful.layout.suit.fullscreen, name = "fullscreen" },
	{ func = awful.layout.suit.magnifier, name = "magnifier" },
	{ func = awful.layout.suit.floating, name = "floating" },
	{ func = lain.layout.centerwork, name = "centerwork" },
	{ func = lain.layout.termfair, name = "termfair" },
	{ func = lain.layout.cascade.tile, name = "cascade_tile" },
	{ func = lain.layout.cascade, name = "cascade" },
}
-- Basic layout definitions for each tag
awful.layout.primaryLayouts = {
	lain.layout.centerwork, -- Entertainment
	lain.layout.centerwork, -- Code
	lain.layout.centerwork, -- Work
	lain.layout.centerwork, -- Obsidian
	awful.layout.suit.fair, -- Misc
}

local primary_tags = awful.tag(awful.util.primaryTagnames, screen.primary, awful.layout.primaryLayouts)

--------------------------------
-- Custom layout settings
--------------------------------

primary_tags[1].master_width_factor = 0.694

--------------------------------
-- Load Our Custom Logic & Modules
--------------------------------

local myFuncs = require("functions") -- customer functions
local stack = require("stack") -- your separate stacking module
local normalKeys = require("devices.normalKeys") -- normal (keyboard) hotkeys

-- Device-specific keymaps
local tartarusKeys = require("devices.tartarus")
local scimitarKeys = require("devices.scimitar")
-- local streamdeckKeys= require("devices.streamdeck")
local macropadKeys = require("devices.macropad")

--------------------------------
-- Combine All Keybinds
--------------------------------

local gears_table_join = gears.table.join

local globalkeys = gears_table_join(
	normalKeys.globalkeys,
	tartarusKeys.globalkeys,
	scimitarKeys.globalkeys,
	-- streamdeckKeys.globalkeys,
	macropadKeys.globalkeys
)

-- Optionally combine client keys from normalKeys (and more if needed)
local clientkeys = gears_table_join(
	normalKeys.clientkeys
	-- e.g. tartarusKeys.clientkeys, scimitarKeys.clientkeys, etc., if you define them
)

local clientbuttons = awful.util.table.join(
	-- Move window on Meta + Left Click
	awful.button({ "Mod4" }, 1, awful.mouse.client.move),

	-- Resize window on Meta + Right Click
	awful.button({ "Mod4" }, 3, awful.mouse.client.resize)
)

root.keys(globalkeys)

--------------------------------
-- Rules
--------------------------------

awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			size_hints_honor = false,
		},
	},
	{
		rule_any = {
			instance = { "DTA", "copyq", "pinentry" },
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin",
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},
			name = { "Event Tester" },
			role = { "AlarmWindow", "ConfigManager", "pop-up" },
		},
		properties = { floating = true },
	},
	{
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = false },
	},
	{
		rule = { class = "Dropdown" },
		properties = {
			floating = true,
			width = 1000,
			height = 600,
			placement = awful.placement.centered,
			ontop = true,
			skip_taskbar = true,
		},
	},
}

--------------------------------
-- Signals
--------------------------------

client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
	if c.wasPromoted and c.maximized then
		c.maximized = false
		c.wasPromoted = false
	end
end)

beautiful.useless_gap = 6

--------------------------------
-- Finish up
----------------------------------
bar.updateVolumeWidget()
-- Done.
