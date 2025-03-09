-- powerarrow theme.lua
-- Updated to use bar.lua for taglist/tasklist button definitions
-- instead of the old awful.util.taglist_buttons or tasklist_buttons

local gears   = require("gears")
local lain    = require("lain")
local awful   = require("awful")
local wibox   = require("wibox")
local dpi     = require("beautiful.xresources").apply_dpi
local naughty = require("naughty")
local bar     = require("bar")   -- This line is important; adjust path if needed

local math, string, os = math, string, os

local theme = {}
theme.dir         = os.getenv("HOME") .. "/.config/awesome/themes/powerarrow"
theme.wallpaper   = theme.dir .. "/wall.png"
theme.font        = "Terminus 9"
theme.fg_normal   = "#FEFEFE"
theme.fg_focus    = "#32D6FF"
theme.fg_urgent   = "#C83F11"
theme.bg_normal   = "#222222"
theme.bg_focus    = "#1E2320"
theme.bg_urgent   = "#3F3F3F"

theme.taglist_fg_focus       = "#00CCFF"
theme.tasklist_bg_focus      = "#222222"
theme.tasklist_fg_focus      = "#00CCFF"
theme.border_width           = dpi(2)
theme.border_normal          = "#3F3F3F"
theme.border_focus           = "#6F6F6F"
theme.border_marked          = "#CC9393"
theme.titlebar_bg_focus      = "#3F3F3F"
theme.titlebar_bg_normal     = theme.bg_normal
theme.titlebar_fg_focus      = theme.fg_focus
theme.menu_height            = dpi(16)
theme.menu_width             = dpi(140)
theme.menu_submenu_icon      = theme.dir .. "/icons/submenu.png"
theme.awesome_icon           = theme.dir .. "/icons/awesome.png"
theme.taglist_squares_sel    = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel  = theme.dir .. "/icons/square_unsel.png"

-- Layout icons
theme.layout_tile            = theme.dir .. "/icons/tile.png"
theme.layout_tileleft        = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom      = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop         = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv           = theme.dir .. "/icons/fairv.png"
theme.layout_fairh           = theme.dir .. "/icons/fairh.png"
theme.layout_spiral          = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle         = theme.dir .. "/icons/dwindle.png"
theme.layout_max             = theme.dir .. "/icons/max.png"
theme.layout_fullscreen      = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier       = theme.dir .. "/icons/magnifier.png"
theme.layout_floating        = theme.dir .. "/icons/floating.png"

-- Example widget icons
theme.widget_ac              = theme.dir .. "/icons/ac.png"
theme.widget_battery         = theme.dir .. "/icons/battery.png"
theme.widget_battery_low     = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty   = theme.dir .. "/icons/battery_empty.png"
theme.widget_brightness      = theme.dir .. "/icons/brightness.png"
theme.widget_mem             = theme.dir .. "/icons/mem.png"
theme.widget_cpu             = theme.dir .. "/icons/cpu.png"
theme.widget_temp            = theme.dir .. "/icons/temp.png"
theme.widget_net             = theme.dir .. "/icons/net.png"
theme.widget_hdd             = theme.dir .. "/icons/hdd.png"
theme.widget_music           = theme.dir .. "/icons/note.png"
theme.widget_music_on        = theme.dir .. "/icons/note_on.png"
theme.widget_music_pause     = theme.dir .. "/icons/pause.png"
theme.widget_music_stop      = theme.dir .. "/icons/stop.png"
theme.widget_vol             = theme.dir .. "/icons/vol.png"
theme.widget_vol_low         = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no          = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute        = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail            = theme.dir .. "/icons/mail.png"
theme.widget_mail_on         = theme.dir .. "/icons/mail_on.png"
theme.widget_task            = theme.dir .. "/icons/task.png"
theme.widget_scissors        = theme.dir .. "/icons/scissors.png"

theme.tasklist_plain_task_name  = true
theme.tasklist_disable_icon     = true
theme.useless_gap               = 0

-- Titlebar icons
theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

--------------------------------------------------------------------------------
-- Additional widgets & code from the original snippet
--------------------------------------------------------------------------------

local lain        = require("lain")
local markup      = lain.util.markup
local separators  = lain.util.separators
local binclock    = require("themes.powerarrow.binclock"){
    height        = dpi(32),
    show_seconds  = true,
    color_active  = theme.fg_normal,
    color_inactive= theme.bg_focus
}

-- Example of using naughty.notify to confirm we got here
naughty.notify({ title = "Powerarrow Theme", text = "theme.lua loaded" })

--------------------------------------------------------------------------------
-- For your wibar arrow separators
--------------------------------------------------------------------------------

local arrow = separators.arrow_left

function theme.powerline_rl(cr, width, height)
    local arrow_depth, offset = height/2, 0

    if arrow_depth < 0 then
        width  = width + 2*arrow_depth
        offset = -arrow_depth
    end

    cr:move_to(offset + arrow_depth, 0)
    cr:line_to(offset + width, 0)
    cr:line_to(offset + width - arrow_depth, height/2)
    cr:line_to(offset + width, height)
    cr:line_to(offset + arrow_depth, height)
    cr:line_to(offset, height/2)
    cr:close_path()
end

--------------------------------------------------------------------------------
-- at_screen_connect
--------------------------------------------------------------------------------

function theme.at_screen_connect(s)
    -- Confirm we reached this function
    naughty.notify({ text = "In theme.at_screen_connect for screen " .. s.index })

    -- Optionally set wallpaper here if you like
    -- gears.wallpaper.maximized(theme.wallpaper, s, true)

    -- Example quake console
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- Promptbox
    s.mypromptbox = awful.widget.prompt()

    -- Layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function () awful.layout.inc(1) end),
        awful.button({}, 3, function () awful.layout.inc(-1) end),
        awful.button({}, 2, function () awful.layout.set(awful.layout.layouts[1]) end),
        awful.button({}, 4, function () awful.layout.inc(1) end),
        awful.button({}, 5, function () awful.layout.inc(-1) end)
    ))

    -- Taglist: use bar.taglist_buttons
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = require("bar").taglist_buttons -- or bar.taglist_buttons if you did local bar
    }

    -- Tasklist: use bar.tasklist_buttons
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = require("bar").tasklist_buttons
    }

    -- Now create the wibox
    s.mywibox = awful.wibar({
        position = "top",
        screen   = s,
        height   = dpi(16),
        bg       = theme.bg_normal,
        fg       = theme.fg_normal
    })

    -- (If you have custom widgets: s.mycoolwidget = ...)

    -- Example "focused_window_class" if you defined it outside
    -- local focused_window_class = ... from your snippet, or require it from somewhere

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        -- Middle
        wibox.container.place(
            -- if you have a big center widget (like "focused_window_class" box)
        ),
        { -- Right
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            -- arrow(...) transitions
            -- CPU, Net, Volume, etc. -- same as your snippet
            -- s.mylayoutbox, if you want to place it here
        },
    }
end

return theme
