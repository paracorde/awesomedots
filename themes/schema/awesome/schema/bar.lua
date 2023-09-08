local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")

spacer = wibox.widget.textbox("")
spacer.forced_width = beautiful.useless_gap*2.5

date = wibox.widget{
    -- {
    --     font = beautiful.icon_large,
    --     valign = "center",
    --     markup = helpers.colorize_foreground("仭", beautiful.bar_prefix_fg),
    --     widget = wibox.widget.textbox
    -- },
    {
        format = "%A %b. %d, %Y",
        widget = wibox.widget.textclock
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal
}

time = wibox.widget{
    -- {
    --     font = beautiful.icon_large,
    --     valign = "center",
    --     markup = helpers.colorize_foreground("匚", beautiful.bar_prefix_fg),
    --     widget = wibox.widget.textbox
    -- },
    {
        format = "%I:%M %p",
        widget = wibox.widget.textclock
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal
}

datetime = wibox.widget{
    date,
    time,
    spacing = dpi(20),
    layout = wibox.layout.fixed.horizontal
}

-- helper function that updates the taglist and sets the icon/color properly depending on the situation
local update_taglist = function (item, tag, index)
    item.font = beautiful.icon_large
    item.forced_width = dpi(25)
    item.halign = "center"
    if tag.selected then
        item.markup = helpers.colorize_foreground(beautiful.taglist_text_focused[index], beautiful.taglist_text_color_focused[index])
    elseif tag.urgent then
        item.markup = helpers.colorize_foreground(beautiful.taglist_text_urgent[index], beautiful.taglist_text_color_urgent[index])
    elseif #tag:clients() > 0 then
        item.markup = helpers.colorize_foreground(beautiful.taglist_text_occupied[index], beautiful.taglist_text_color_occupied[index])
    else
        item.markup = helpers.colorize_foreground(beautiful.taglist_text_empty[index], beautiful.taglist_text_color_empty[index])
    end
end

local recording = wibox.widget{
    {
        font = beautiful.icon,
        markup = helpers.colorize_foreground("苭", x.color1),
        widget = wibox.widget.textbox
    },
    {
        font = beautiful.font_small,
        markup = helpers.colorize_foreground(" recording in progress...", beautiful.titlebar_fg),
        widget = wibox.widget.textbox
    },
    layout = wibox.layout.fixed.horizontal
}

helpers.add_hover_cursor(recording, "hand1")
recording:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("pkill recordmydesktop")
        recording.visible = false
    end)
})
recording.visible = false

awesome.connect_signal("keys::recording", function()
    recording.visible = true
end)

awful.screen.connect_for_each_screen(function(s)
    s.taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        widget_template = {
            widget = wibox.widget.textbox,
            create_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
            update_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
        }
    }

    s.wibox = awful.wibar{
        screen = s,
        ontop = true,
        type = "dock",
        restrict_workarea = true,
        position = beautiful.bar_position,
        height = beautiful.bar_height,
        bg = beautiful.bar_bg,
        border_color = beautiful.border_color_active,
        border_width = beautiful.border_width,
        margins = {left = -beautiful.border_width, top = -beautiful.border_width, right = -beautiful.border_width, bottom = 0}
    }

    s.wibox:setup{
        {
            spacer,
            s.taglist,
            layout = wibox.layout.fixed.horizontal
        },
        {
            recording,
            widget = wibox.container.place
        },
        {
            datetime,
            spacer,
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end)

local function ensure_fullscreen_above_bar(c)
    local s = awful.screen.focused()
    if c.fullscreen then
        s.wibox.ontop = false
    else
        s.wibox.ontop = true
    end
end

client.connect_signal("focus", ensure_fullscreen_above_bar)
client.connect_signal("unfocus", ensure_fullscreen_above_bar)
client.connect_signal("property::fullscreen", ensure_fullscreen_above_bar)