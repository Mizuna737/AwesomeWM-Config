-- devices/macropad.lua
-- 5-button pad with short press vs. long press. 
-- Assume short press => F21..F25, long press => F26..F30.

local gears = require("gears")
local awful = require("awful")
local myFuncs = require("functions")

local macropad = {}

macropad.globalkeys = gears.table.join(
    -- Button 1 short => F21 => Switch to WS1
    awful.key({}, "F21", function()
        myFuncs.viewWorkspace(1)
    end, {description = "Go to workspace 1 (short)", group = "macropad"}),

    -- Button 1 long => F26 => Launch dev environment
    awful.key({}, "F26", function()
        awful.spawn("alacritty")    -- Dev terminal
        myFuncs.moveWindowToWorkspace(1)
        myFuncs.viewWorkspace(1)
    end, {description = "Setup dev environment on WS1 (long)", group = "macropad"}),

    -- Button 2 short => F22 => WS2
    awful.key({}, "F22", function()
        myFuncs.viewWorkspace(2)
    end, {description = "Go to workspace 2", group = "macropad"}),

    -- Button 2 long => F27 => Comms environment
    awful.key({}, "F27", function()
        awful.spawn("slack")
        awful.spawn("discord")
        myFuncs.moveWindowToWorkspace(2)
        myFuncs.viewWorkspace(2)
    end, {description = "Setup comms on WS2", group = "macropad"}),

    -- Button 3 short => F23 => WS3
    awful.key({}, "F23", function()
        myFuncs.viewWorkspace(3)
    end, {description = "Go to workspace 3", group = "macropad"}),

    -- Button 3 long => F28 => Research/Browser
    awful.key({}, "F28", function()
        myFuncs.openBrowser()
        myFuncs.moveWindowToWorkspace(3)
        myFuncs.viewWorkspace(3)
    end, {description = "Setup browser environment on WS3", group = "macropad"}),

    -- Button 4 short => F24 => WS4
    awful.key({}, "F24", function()
        myFuncs.viewWorkspace(4)
    end, {description = "Go to workspace 4", group = "macropad"}),

    -- Button 4 long => F29 => Leisure
    awful.key({}, "F29", function()
        awful.spawn("rss-reader-app")
        myFuncs.moveWindowToWorkspace(4)
        myFuncs.viewWorkspace(4)
    end, {description = "Setup leisure environment on WS4", group = "macropad"}),

    -- Button 5 short => F25 => WS5
    awful.key({}, "F25", function()
        myFuncs.viewWorkspace(5)
    end, {description = "Go to workspace 5", group = "macropad"}),

    -- Button 5 long => F30 => Work environment
    awful.key({}, "F30", function()
        awful.spawn("teams")
        awful.spawn("jira-client-app")
        myFuncs.moveWindowToWorkspace(5)
        myFuncs.viewWorkspace(5)
    end, {description = "Setup day job environment on WS5", group = "macropad"})
)

return macropad
