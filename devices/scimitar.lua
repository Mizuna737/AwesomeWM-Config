-- devices/scimitar.lua
-- The Corsair Scimitar with 12 side buttons.
-- We'll call them XF86Tools1..XF86Tools12 in keyd. 
-- "Mouse-L2" might be Control on your keyboard to create a second layer.

local gears = require("gears")
local awful = require("awful")
local myFuncs = require("functions")

local scimitar = {}
local l2 = "Control"  -- "Mouse-L2"

scimitar.globalkeys = gears.table.join(
    -- Normal mode
    awful.key({}, "XF86Tools1", function()
        awful.spawn("flameshot gui")
    end, {description = "Screenshot", group = "scimitar"}),

    awful.key({}, "XF86Tools2", function()
        awful.spawn("dunstctl set-paused toggle")
    end, {description = "Toggle notifications", group = "scimitar"}),

    awful.key({}, "XF86Tools3", function()
        awful.spawn("gedit")
    end, {description = "Open quick notes", group = "scimitar"}),

    awful.key({}, "XF86Tools4", function()
        awful.spawn("xdotool key super+d")
    end, {description = "Show desktop", group = "scimitar"}),

    -- Button 5 might be your "tap for primary window, hold for drag" in hardware, so no direct binding

    awful.key({}, "XF86Tools6", function()
        myFuncs.openSystemMonitor()
    end, {description = "Open system monitor", group = "scimitar"}),

    awful.key({}, "XF86Tools7", function()
        awful.spawn("copyq toggle")
    end, {description = "Toggle clipboard manager", group = "scimitar"}),

    awful.key({}, "XF86Tools8", function()
        awful.spawn("alacritty -e btop")
    end, {description = "Open dashboard", group = "scimitar"}),

    awful.key({}, "XF86Tools9", function()
        awful.spawn("spotify")
    end, {description = "Open music player", group = "scimitar"}),

    awful.key({}, "XF86Tools10", function()
        awful.spawn("rofi -show p -modi p:rofi-power-menu")
    end, {description = "Open power menu", group = "scimitar"}),

    awful.key({}, "XF86Tools11", function()
        myFuncs.showCheatsheet() -- e.g. a function that notifies your custom hotkeys
    end, {description = "Show cheatsheet", group = "scimitar"}),

    awful.key({}, "XF86Tools12", function()
        awful.spawn("gnome-control-center")
    end, {description = "Open system settings", group = "scimitar"})
)

-- Modified mode (hold l2 = Control)
scimitar.globalkeys = gears.table.join(scimitar.globalkeys,
    awful.key({l2}, "XF86Tools1", function()
        awful.spawn("alacritty --class dropdown")
    end, {description = "Dropdown terminal overlay", group = "scimitar"}),

    awful.key({l2}, "XF86Tools2", function()
        myFuncs.openFileManager()
    end, {description = "Open file manager overlay", group = "scimitar"})

    -- etc. for Tools3..Tools12
)

return scimitar
