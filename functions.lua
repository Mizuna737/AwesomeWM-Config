-- functions.lua
-- Stores all custom logic in camelCase for easy reusability.

local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")
local lain    = require("lain")
local bar     = require("bar")
local hotkeys_popup = require("awful.hotkeys_popup")
                      require("awful.hotkeys_popup.keys")
local M = {}

--------------------------------
-- Tag Navigation
--------------------------------

function M.viewPopulatedTag(direction)
    local screen = awful.screen.focused()
    local currentTag = screen.selected_tag
    local tags = screen.tags
    local targetTag

    if not currentTag then return end

    if direction == "next" then
        for i = (currentTag.index % #tags) + 1, #tags do
            if #tags[i]:clients() > 0 then
                targetTag = tags[i]
                break
            end
        end
        if not targetTag then
            for i = 1, currentTag.index - 1 do
                if #tags[i]:clients() > 0 then
                    targetTag = tags[i]
                    break
                end
            end
        end
    elseif direction == "previous" then
        for i = (currentTag.index - 2 + #tags) % #tags + 1, 1, -1 do
            if #tags[i]:clients() > 0 then
                targetTag = tags[i]
                break
            end
        end
        if not targetTag then
            for i = #tags, currentTag.index + 1, -1 do
                if #tags[i]:clients() > 0 then
                    targetTag = tags[i]
                    break
                end
            end
        end
    end

    if targetTag then
        targetTag:view_only()
    end
end

function M.viewWorkspace(index)
    local s = awful.screen.focused()
    local t = s.tags[index]
    if t then
        t:view_only()
    end
end

function M.moveWindowToWorkspace(index)
    local c = client.focus
    local s = awful.screen.focused()
    local t = s.tags[index]
    if c and t then
        c:move_to_tag(t)
        t:view_only()
    end
end

--------------------------------
-- Window Focus / Mouse Centering
--------------------------------

function M.centerMouseOnFocusedClient()
    local c = client.focus
    if c then
        local geometry = c:geometry()
        local x = geometry.x + geometry.width / 2
        local y = geometry.y + geometry.height / 2
        mouse.coords({ x = x, y = y }, true)
    end
end

local function onNewWindow(callback)
    local existingClients = client.get()
    local timer = gears.timer({ timeout = 0.1 })
    timer:connect_signal("timeout", function()
        local currentClients = client.get()
        if #currentClients > #existingClients then
            for _, c in ipairs(currentClients) do
                if not gears.table.hasitem(existingClients, c) then
                    timer:stop()
                    callback(c)
                    break
                end
            end
        end
        existingClients = currentClients
    end)
    timer:start()
end

function M.centerMouseOnNewWindow()
    onNewWindow(function(c)
        M.centerMouseOnFocusedClient()
    end)
end

function M.moveFocus(direction)
   awful.client.focus.bydirection(direction)
    M.centerMouseOnFocusedClient()
end

function M.swapWindow(direction)
    awful.client.swap.bydirection(direction)
    gears.timer.delayed_call(M.centerMouseOnFocusedClient)
end

--------------------------------
-- Volume / Multimedia
--------------------------------

function M.volumeControl(action)
    if action == "up" then
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +1%", false)
    elseif action == "down" then
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -1%", false)
    elseif action == "mute" then
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
    end
    bar.updateVolumeWidget()
end

--------------------------------
-- Layout or Misc
--------------------------------

function M.nextLayoutForTag()
    local a = awful.layout.suit
    local l = lain.layout

    local tagLayouts = {
        ["Entertainment"] = { l.centerwork, a.tile, a.magnifier },
        ["Code"]          = { l.centerwork, a.fair, a.spiral.dwindle },
        ["Work"]          = { l.centerwork, a.spiral.dwindle, a.magnifier, l.cascade.tile },
        ["Obsidian"]      = { l.centerwork, l.cascade.tile },
        ["Misc"]          = { a.fair, a.floating }
    }

    local screen = awful.screen.focused()
    local tag = screen.selected_tag
    if not tag then return end

    local layouts = tagLayouts[tag.name]
    if not layouts then return end

    local currentLayout = tag.layout
    local currentIndex = gears.table.hasitem(layouts, currentLayout)
    if not currentIndex then
        tag.layout = layouts[1]
    else
        local nextIndex = (currentIndex % #layouts) + 1
        tag.layout = layouts[nextIndex]
    end
end

function M.lockScreen()
    awful.spawn("xset dpms force standby")
end

function M.showCheatsheet()
    hotkeys_popup.show_help(nil, awful.screen.focused()) 
end

function M.promoteFocusedWindow(c)
    if c == awful.client.getmaster() then
        -- Already master: toggle maximized
        c.maximized = not c.maximized
        c.wasPromoted = c.maximized   -- Only “true” if now maximized
        gears.timer.delayed_call(M.centerMouseOnFocusedClient)
        c:raise()
    else
        -- Not master yet: swap into master
        c:swap(awful.client.getmaster())
        c.wasPromoted = true         -- Mark this as a “promoted” window
        gears.timer.delayed_call(M.centerMouseOnFocusedClient)
    end
end

--------------------------------
-- App Launching
--------------------------------

function M.openBrowser()
    awful.spawn("zen-browser")
end


function M.openFileManager()
    awful.spawn.with_shell("QT_QPA_PLATFORMTHEME=qt5ct QT_STYLE_OVERRIDE=kvantum dolphin")
end

function M.openEditor()
    awful.spawn("vscodium")
end

function M.openRofi()
    awful.spawn("rofi -show combi -combi-modes \"window,drun\"")
    M.centerMouseOnNewWindow()
end

function M.openNew(appCmd)
    -- Spawn the application
    awful.spawn.with_shell(appCmd)
    -- Use your existing function to center mouse on the newly created window
    -- (It likely uses gears.timer or a client creation signal to detect the new window.)
    gears.timer.delayed_call(M.centerMouseOnNewWindow)
end

function M.findExisting(app, appCmd)
    local appCmd = appCmd or app
    local lowerCmd = (app or ""):lower()
    local matchedClient = nil

    -- If the focused client is a match, promote and return.
    local fc = client.focus
    if fc and (fc.class or ""):lower():match(lowerCmd) then
        M.promoteFocusedWindow(fc)
        return
    end

    -- Search through all current clients
    for _, c in ipairs(client.get()) do
        -- Compare the window class (or instance) with appCmd
        local class = (c.class or ""):lower()
        if class:match(lowerCmd) then
            matchedClient = c
            break
        end
    end

    if matchedClient then
        -- If the matched client is already focused, promote it
        if client.focus == matchedClient then
            M.promoteFocusedWindow(matchedClient)
        else
            -- Switch to the workspace (tag) containing matchedClient, if not already on it
            local t = matchedClient.first_tag
            if t then
                t:view_only()  -- Switch to the tag
            end

            -- Now focus, raise, and center mouse
            client.focus = matchedClient
            matchedClient:raise()
            gears.timer.delayed_call(M.centerMouseOnFocusedClient)
        end
    else
        M.openNew(appCmd)
    end
    
end

return M
