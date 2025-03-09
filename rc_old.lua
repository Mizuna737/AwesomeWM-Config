--[[

     Awesome WM configuration template
     github.com/lcpz

--]]

-- {{{ Required libraries

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup")
                      require("awful.hotkeys_popup.keys")
local mytable       = awful.util.table or gears.table -- 4.{0,1} compatibility

-- }}}

-- {{{ Error handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    }
end

-- Handle runtime errors after startup
do
    local in_error = false

    awesome.connect_signal("debug::error", function (err)
        if in_error then return end

        in_error = true

        naughty.notify {
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        }

        in_error = false
    end)
end

-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({ "urxvtd", "unclutter -root", "~/.screenlayout/DefaultLayout.sh", "~/.config/awesome/autorun.sh"}) -- comma-separated entries

-- This function implements the XDG autostart specification

awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart --search-paths ' ..
    '"${XDG_CONFIG_HOME:-$HOME/.config}/autostart:${XDG_CONFIG_DIRS:-/etc/xdg}/autostart";' -- https://github.com/jceb/dex
)


-- }}}

-- {{{ Variable definitions

local themes = {
    "blackburn",       -- 1
    "copland",         -- 2
    "dremora",         -- 3
    "holo",            -- 4
    "multicolor",      -- 5
    "powerarrow",      -- 6
    "powerarrow-dark", -- 7
    "rainbow",         -- 8
    "steamburn",       -- 9
    "vertex"           -- 10
}

local chosen_theme = themes[6]
local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "alacritty"
local vi_focus     = false -- vi-like client focus https://github.com/lcpz/awesome-copycats/issues/275
local cycle_prev   = true  -- cycle with only the previously focused client or all https://github.com/lcpz/awesome-copycats/issues/274
local editor       = os.getenv("VSCodium") or "nvim"
local browser      = "zen-browser"



awful.util.terminal = terminal
awful.util.primaryTagnames = {"Entertainment", "Code", "Work", "Obsidian","Misc"}

--[[ -- Define layouts for each tag
local primary_tag_layouts = {
    { lain.layout.centerwork, awful.layout.suit.tile, awful.layout.suit.max },    -- Layouts for "Entertainment"
    { lain.layout.centerwork, awful.layout.suit.fair, awful.layout.suit.spiral }, -- Layouts for "Code"
    { awful.layout.centerwork, awful.layout.suit.tile, awful.layout.suit.max },   -- Layouts for "Work"
    { awful.layout.suit.floating, awful.layout.suit.tile },                      -- Layouts for "Misc"
}

-- Create tags with their specific layout options
local primary_tags = {}
for i, tagname in ipairs(awful.util.primaryTagnames) do
    primary_tags[i] = awful.tag.add(tagname, {
        screen = screen.primary,
        layouts = primary_tag_layouts[i] or { awful.layout.suit.tile },
    })
end ]]


awful.layout.primaryLayouts = {

    lain.layout.centerwork,
    lain.layout.centerwork,
    lain.layout.centerwork,
    lain.layout.centerwork,
    awful.layout.suit.fair,
    

}



local primary_tags = awful.tag(awful.util.primaryTagnames, screen.primary, awful.layout.primaryLayouts)

-- Set master width for specific tags if needed
primary_tags[1].master_width_factor = 0.694  -- Tag "Entertainment" gets a slightly larger master width

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2


awful.util.taglist_buttons = mytable.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
    end)
)

awful.util.tasklist_buttons = mytable.join(
     awful.button({ }, 1, function(c)
         if c == client.focus then
             c.minimized = true
         else
             c:emit_signal("request::activate", "tasklist", { raise = true })
         end
     end),
     awful.button({ }, 3, function()
         awful.menu.client_list({ theme = { width = 250 } })
     end),
     awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
     awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
)

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))

-- }}}

-- {{{ Menu

-- Create a launcher widget and a main menu
local myawesomemenu = {
   { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "Manual", string.format("%s -e man awesome", terminal) },
   { "Edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
   { "Restart", awesome.restart },
   { "Quit", function() awesome.quit() end },
}

awful.util.mymainmenu = freedesktop.menu.build {
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
}

-- Hide the menu when the mouse leaves it
--[[
awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function()
    if not awful.util.mymainmenu.active_child or
       (awful.util.mymainmenu.wibox ~= mouse.current_wibox and
       awful.util.mymainmenu.active_child.wibox ~= mouse.current_wibox) then
        awful.util.mymainmenu:hide()
    else
        awful.util.mymainmenu.active_child.wibox:connect_signal("mouse::leave",
        function()
            if awful.util.mymainmenu.wibox ~= mouse.current_wibox then
                awful.util.mymainmenu:hide()
            end
        end)
    end
end)
--]]

-- Set the Menubar terminal for applications that require it
--menubar.utils.terminal = terminal

-- }}}

-- {{{ Screen

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized or c.fullscreen then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)


-- }}}

-- {{{ Mouse bindings

root.buttons(mytable.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
        awful.button({ modkey }, 4, function ()
        local screen = awful.screen.focused()
        local current_tag = screen.selected_tag
        local tags = screen.tags
        local next_tag = nil

        -- Find the next populated tag
        for i = (current_tag.index % #tags) + 1, #tags do
            if #tags[i]:clients() > 0 then
                next_tag = tags[i]
                break
            end
        end

        -- Wrap around to the beginning if needed
        if not next_tag then
            for i = 1, current_tag.index - 1 do
                if #tags[i]:clients() > 0 then
                    next_tag = tags[i]
                    break
                end
            end
        end

        -- Switch to the next populated tag if found
        if next_tag then
            next_tag:view_only()
        end
    end),
    awful.button({ modkey }, 5, function ()
        local screen = awful.screen.focused()
        local current_tag = screen.selected_tag
        local tags = screen.tags
        local prev_tag = nil

        -- Find the previous populated tag
        for i = (current_tag.index - 2 + #tags) % #tags + 1, 1, -1 do
            if #tags[i]:clients() > 0 then
                prev_tag = tags[i]
                break
            end
        end

        -- Wrap around to the end if needed
        if not prev_tag then
            for i = #tags, current_tag.index + 1, -1 do
                if #tags[i]:clients() > 0 then
                    prev_tag = tags[i]
                    break
                end
            end
        end

        -- Switch to the previous populated tag if found
        if prev_tag then
            prev_tag:view_only()
        end
    end)
)
)


-- }}}
-- {{{ Functions
-- Generalized function to view the next or previous populated tag
function viewPopulatedTag(direction)
    local screen = awful.screen.focused()
    local current_tag = screen.selected_tag
    local tags = screen.tags
    local target_tag = nil

    if direction == "next" then
        -- Find the next populated tag
        for i = (current_tag.index % #tags) + 1, #tags do
            if #tags[i]:clients() > 0 then
                target_tag = tags[i]
                break
            end
        end
        -- Wrap around to the beginning if no populated tag is found
        if not target_tag then
            for i = 1, current_tag.index - 1 do
                if #tags[i]:clients() > 0 then
                    target_tag = tags[i]
                    break
                end
            end
        end
    elseif direction == "previous" then
        -- Find the previous populated tag
        for i = (current_tag.index - 2 + #tags) % #tags + 1, 1, -1 do
            if #tags[i]:clients() > 0 then
                target_tag = tags[i]
                break
            end
        end
        -- Wrap around to the end if no populated tag is found
        if not target_tag then
            for i = #tags, current_tag.index + 1, -1 do
                if #tags[i]:clients() > 0 then
                    target_tag = tags[i]
                    break
                end
            end
        end
    end

    -- Switch to the found populated tag if there is one
    if target_tag then
        target_tag:view_only()
    end
end


function center_mouse_on_focused_client()
    local c = client.focus
    if c then
        local geometry = c:geometry()
        local x = geometry.x + geometry.width / 2
        local y = geometry.y + geometry.height / 2
        mouse.coords({ x = x, y = y }, true)
    end
end

local function on_new_window(callback)
    local existing_clients = client.get()  -- Capture the initial set of managed clients

    -- Timer to check for new clients every 0.1 seconds
    local timer = gears.timer { timeout = 0.1 }
    timer:connect_signal("timeout", function()
        local current_clients = client.get()  -- Get the current list of clients

        -- Check if a new client has appeared
        if #current_clients > #existing_clients then
            -- Find the new client
            for _, c in ipairs(current_clients) do
                if not gears.table.hasitem(existing_clients, c) then
                    timer:stop()  -- Stop the timer once we detect a new window
                    callback(c)   -- Run the callback function with the new client
                    break
                end
            end
        end

        -- Update the list of existing clients
        existing_clients = current_clients
    end)

    timer:start()
end

local function center_mouse_on_new_window()
    on_new_window(function(c)
        center_mouse_on_focused_client()
    end)
end

function volume_control(action)
    if action == "up" then
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +1%", false)
    elseif action == "down" then
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -1%", false)
    elseif action == "mute" then
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
    end
    update_volume_widget()
end

awesome.connect_signal("org.awesomewm.awful.volume_update", update_volume_widget)

local function next_layout()
    local a = awful.layout.suit
    local l = lain.layout
    local tagLayouts = {

        ["Entertainment"] = { l.centerwork, a.tile, a.magnifier },      -- Layouts for "Entertainment"
        ["Code"] = { l.centerwork, a.fair, a.spiral.dwindle },            -- Layouts for "Code"
        ["Work"] = { l.centerwork, a.spiral.dwindle, a.magnifier, l.cascade.tile },              -- Layouts for "Work"
        ["Obsidian"] = { l.centerwork, l.cascade.tile },                -- Layouts for "Obsidian"
        ["Misc"] = { a.fair, a.floating },                                  -- Layouts for "Misc"
        
    }
        
    local screen = awful.screen.focused()
    local tag = screen.selected_tag

    if not tag then
        return
    end

    local layouts = tagLayouts[tag.name]
    local currentLayout = tag.layout
    local currentIndex = gears.table.hasitem(layouts, currentLayout)

    if not currentIndex then
        tag.layout = layouts[1]
    else
        local nextIndex = (currentIndex % #layouts) + 1
        tag.layout = layouts[nextIndex]
    end
end

awesome.connect_signal("switch::layout", next_layout)

-- }}}
-- {{{ Stacking
local stack = require("stack")

-- }}}
-- {{{ Key bindings

globalkeys = mytable.join(

    -- Stacks
    awful.key({ "Mod4", "Shift" }, "n", function()
        local client = client.focus
        if client then
            stack.stackClients(client)
        end
    end, {description = "Stack client with next client in tree", group = "Stacking"}),
    awful.key({ "Mod4", "Shift" }, "l", function()
            stack.listStacks()
    end, {description = "list all stacks", group = "Stacking"}),
    awful.key({ "Mod4", "Shift" }, "c", function()
        stack.clearStacks()
    end, {description = "clears all stacks", group = "Stacking"}),
    awful.key({ "Mod4", "Shift" }, "u", function()
        stack.cycleStack()
    end, {description = "cycles through a stack", group = "Stacking"}),

    -- Audio
    awful.key({}, "XF86AudioRaiseVolume", function() volume_control("up") end,
        {description = "increase volume", group = "volume"}),
    awful.key({}, "XF86AudioLowerVolume", function() volume_control("down") end,
        {description = "decrease volume", group = "volume"}),
    awful.key({}, "XF86AudioMute", function() volume_control("mute") end,
        {description = "toggle mute", group = "volume"}),

    -- X screen locker
    awful.key({ altkey, "Control" }, "l", function () os.execute(scrlocker) end,
              {description = "lock screen", group = "hotkeys"}),

    -- Show help
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),

    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
              {description = "view  previous nonempty", group = "tag"}),

    -- Default client focus
    awful.key({ altkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ altkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- By-direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
            gears.timer.delayed_call(center_mouse_on_focused_client)
        end,
        {description = "focus down", group = "client"}),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
            gears.timer.delayed_call(center_mouse_on_focused_client)
        end,
        {description = "focus up", group = "client"}),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
            gears.timer.delayed_call(center_mouse_on_focused_client)
        end,
        {description = "focus left", group = "client"}),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
            gears.timer.delayed_call(center_mouse_on_focused_client)
        end,
        {description = "focus right", group = "client"}),

    -- Menu
    awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation

    -- Function to center the mouse on the focused client

-- Keybindings to swap window in the specified direction and center mouse
awful.key({ modkey, "Shift" }, "h", 
    function()
        awful.client.swap.bydirection("left")
        gears.timer.delayed_call(center_mouse_on_focused_client)
    end,
    { description = "swap with client to the left", group = "client" }),

awful.key({ modkey, "Shift" }, "j", 
    function()
        awful.client.swap.bydirection("down")
        gears.timer.delayed_call(center_mouse_on_focused_client)
    end,
    { description = "swap with client below", group = "client" }),

awful.key({ modkey, "Shift" }, "k", 
    function()
        awful.client.swap.bydirection("up")
        gears.timer.delayed_call(center_mouse_on_focused_client)
    end,
    { description = "swap with client above", group = "client" }),

awful.key({ modkey, "Shift" }, "l", 
    function()
        awful.client.swap.bydirection("right")
        gears.timer.delayed_call(center_mouse_on_focused_client)
    end,
    { description = "swap with client to the right", group = "client" }),
    awful.key({ modkey,           }, "Tab",
        function ()
            if cycle_prev then
                awful.client.focus.history.previous()
            else
                awful.client.focus.byidx(-1)
            end
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "cycle with previous/go back", group = "client"}),
    awful.key({altkey,}, "Tab",
        function()
            local screen = awful.screen.focused()
            local clients = screen.selected_tag:clients()

            if #clients < 2 then
                return  -- Nothing to cycle if there are fewer than 2 windows
            end

            -- Swap the master client with the next client
            clients[1]:swap(clients[2])

            -- Move the previous master to the end of the list
            for i = 2, #clients - 1 do
                clients[i]:swap(clients[i + 1])
            end
        end,
        {description = "cycle through windows (like alt+tab on windows)", group = "client"}),

    -- Show/hide wibox
    awful.key({ modkey }, "b", function ()
            for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
        end,
        {description = "toggle wibox", group = "awesome"}),

    -- On-the-fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end,
              {description = "increment useless gaps", group = "tag"}),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end,
              {description = "decrement useless gaps", group = "tag"}),

    -- Dynamic tagging
    -- awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end,
    --           {description = "add new tag", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end,
    --           {description = "rename tag", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end,
    --           {description = "move tag to the left", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end,
    --           {description = "move tag to the right", group = "tag"}),
    -- awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end,
    --           {description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () 
        awful.spawn(terminal)
        center_mouse_on_new_window()
     end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey, altkey    }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, altkey    }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, altkey, "Conrtrol"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, altkey, "Control"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.spawn.with_shell("rofi -modes combi -combi-modes \"window,drun\" -show combi")                end,
              {description = "launch rofi", group = "launcher"}),
    awful.key({ altkey   }, "space", function () next_layout() end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n", function ()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal("request::activate", "key.unminimize", {raise = true})
        end
    end, {description = "restore minimized", group = "client"}),

    -- Dropdown application
    awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end,
              {description = "dropdown application", group = "launcher"}),

    -- Widgets popups
    awful.key({ altkey, }, "c", function () if beautiful.cal then beautiful.cal.show(7) end end,
              {description = "show calendar", group = "widgets"}),
    awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
              {description = "show filesystem", group = "widgets"}),
    awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end,
              {description = "show weather", group = "widgets"}),


    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
        function ()
            os.execute("mpc toggle")
            beautiful.mpd.update()
        end,
        {description = "mpc toggle", group = "widgets"}),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            os.execute("mpc stop")
            beautiful.mpd.update()
        end,
        {description = "mpc stop", group = "widgets"}),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            os.execute("mpc prev")
            beautiful.mpd.update()
        end,
        {description = "mpc prev", group = "widgets"}),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            os.execute("mpc next")
            beautiful.mpd.update()
        end,
        {description = "mpc next", group = "widgets"}),
    awful.key({ altkey }, "0",
        function ()
            local common = { text = "MPD widget ", position = "top_middle", timeout = 2 }
            if beautiful.mpd.timer.started then
                beautiful.mpd.timer:stop()
                common.text = common.text .. lain.util.markup.bold("OFF")
            else
                beautiful.mpd.timer:start()
                common.text = common.text .. lain.util.markup.bold("ON")
            end
            naughty.notify(common)
        end,
        {description = "mpc on/off", group = "widgets"}),

    -- Copy primary to clipboard (terminals to gtk)
    awful.key({ modkey }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end,
              {description = "copy terminal to gtk", group = "hotkeys"}),
    -- Copy clipboard to primary (gtk to terminals)
    awful.key({ modkey }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end,
              {description = "copy gtk to terminal", group = "hotkeys"}),

    -- User programs
    awful.key({ modkey }, "q", function () 
        awful.spawn(browser) 
        center_mouse_on_new_window()
    end,
              {description = "run browser", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "s", function () awful.spawn("flameshot gui") end,
              {description = "run flameshot gui", group = "launcher"}),

    -- Default
    --[[ Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
    --]]
    --[[ dmenu
    awful.key({ modkey }, "x", function ()
            os.execute(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
            beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
        end,
        {description = "show dmenu", group = "launcher"}),
    --]]
    -- alternatively use rofi, a dmenu-like application with more features
    -- check https://github.com/DaveDavenport/rofi for more details
    --[[ rofi
    awful.key({ modkey }, "x", function ()
            os.execute(string.format("rofi -show %s -theme %s",
            'run', 'dmenu'))
        end,
        {description = "show rofi", group = "launcher"}),
    --]]
    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
    --]]
)

clientkeys = mytable.join(
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client,
              {description = "magnify client", group = "client"}),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, }, "Escape",      function (c) 
        c:kill()
        gears.timer.start_new(0.1, function()
            center_mouse_on_focused_client()
            return false  -- Stop the timer after one call
        end)
    end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", 
    function (c) 
        if c then
            if c == awful.client.getmaster() then
                -- Toggle maximization if the client is already the master
                c.maximized = not c.maximized
                gears.timer.delayed_call(center_mouse_on_focused_client)
                c:raise()
            else
                -- Swap with master if the client is not the master
                c:swap(awful.client.getmaster())
                gears.timer.delayed_call(center_mouse_on_focused_client)
            end
        end
    end,
    { description = "maximize if master or swap with master", group = "client" }),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = mytable.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = mytable.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end),
        awful.button({ modkey }, 4, function ()
        viewPopulatedTag("next")
    end),
    awful.button({ modkey }, 5, function ()
        viewPopulatedTag("previous")
    end)
)

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     callback = awful.client.setslave,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}

-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = mytable.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, { size = 16 }) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = vi_focus})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- switch to parent after closing child window
local function backham()
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c then
        client.focus = c
        c:raise()
    end
end

-- attach to minimized state
client.connect_signal("property::minimized", backham)
-- attach to closed state
client.connect_signal("unmanage", backham)
-- ensure there is always a selected client during tag switching or logins
tag.connect_signal("property::selected", backham)

-- }}}

-- Gaps
beautiful.useless_gap = 10

-- Autostart (Load Late)

awful.spawn("bash ~/.config/awesome/autorun.sh")