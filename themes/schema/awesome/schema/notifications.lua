local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")

local helpers = require("helpers")

local default_icon = "/"

local app_config = {
    ['battery'] = {icon = "/", title = false, show_image = false},
    ['charger'] = {icon = "/", title = false, show_image = false},
    ['volume'] = {icon = "/", title = false, show_image = false},
    ['brightness'] = {icon = "/", title = false, show_image = false},
    ['screenshot'] = {icon = "竄", title = false, show_image = true},
    ['night_mode'] = {icon = "/", title = false, show_image = false},
    ['mpd'] = {icon = "/", title = false, show_image = true},
    ['email'] = {icon = "/", title = true, show_image = false},
}

local urgency_colors = {
    ['low'] = x.color4,
    ['normal'] = x.color3,
    ['critical'] = x.color1,
}

-- anti-aliasing
local notification_bg = beautiful.notification_bg
beautiful.notification_bg = "#00000000"

naughty.connect_signal("request::display", function(n)
    local icon_box
    local icon
    if app_config[n.app_name] then
        icon = app_config[n.app_name].icon
        title_visible = app_config[n.app_name].title
    else
        icon = default_icon
        title_visible = true
    end
    if not n.icon then
        n.icon = icon
    end
    if n.icon and n.icon:wlen() > 1 then
        icon_box = wibox.widget{
            {
                {
                    valign = "center",
                    halign = "center",
                    forced_height = dpi(64),
                    forced_width = dpi(64),
                    image = n.icon,
                    notification = n,
                    widget = naughty.widget.icon
                },
                -- border_color = beautiful.border_color,
                -- border_width = beautiful.border_width,
                shape = helpers.rrect(beautiful.border_radius),
                widget = wibox.container.background
            },
            -- increase forced_height and forced_width to add padding around the icon
            forced_height = dpi(64),
            forced_width = dpi(64),
            widget = wibox.container.place
        }
    else
        local color = urgency_colors[n.urgency]
        n.text_icon = wibox.widget{
            halign = "center",
            valign = "center",
            font = beautiful.icon_large,
            text = n.icon,
            widget = wibox.widget.textbox
        }
        icon_box = wibox.widget{
            n.text_icon,
            fg = color,
            forced_height = dpi(20),
            forced_width = dpi(20),
            widget = wibox.container.background
        }
    end

    local actions = wibox.widget{
        notification = n,
        base_layout = wibox.widget{
            spacing = dpi(2),
            layout = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    {
                        id = 'text_role',
                        font = beautiful.notification_font,
                        widget = wibox.widget.textbox
                    },
                    left = dpi(6),
                    right = dpi(0),
                    widget = wibox.container.margin
                },
                widget = wibox.container.place
            },
            bg = notification_bg,
            forced_height = dpi(25),
            forced_width = dpi(50),
            widget = wibox.container.background
        },
        style = {
            underline_normal = false,
            underline_selected = true
        },
        widget = naughty.list.actions
    }

    naughty.layout.box{
        notification = n,
        type = "notification",
        widget_template = {
            {
                {
                    {
                        {
                            {
                                halign = "center",
                                visible = title_visible,
                                font = beautiful.notification_font,
                                markup = "<b>"..n.title.."</b>",
                                widget = wibox.widget.textbox
                            },
                            margins = {top=beautiful.notification_margin, left=0, right=0, bottom=0},
                            widget = wibox.container.margin
                        },
                        visible = title_visible,
                        bg = beautiful.notification_title_bg,
                        widget = wibox.container.background
                    },
                    {
                        {
                            icon_box,
                            helpers.horizontal_pad(beautiful.notification_margin),
                            {
                                nil,
                                {
                                    halign = "center",
                                    valign = "center",
                                    widget = naughty.widget.message
                                },
                                {
                                    actions,
                                    shape = helpers.rrect(dpi(4)),
                                    widget = wibox.container.background,
                                    visible = n.actions and #n.actions > 0
                                },
                                layout = wibox.layout.align.vertical
                            },
                            layout = wibox.layout.fixed.horizontal
                        },
                        margins = beautiful.notification_margin,
                        widget = wibox.container.margin
                    },
                    layout = wibox.layout.fixed.vertical
                },
                strategy = "max",
                width = beautiful.notification_max_width or dpi(350),
                height = beautiful.notification_max_height or dpi(180),
                widget = wibox.container.constraint
            },
            bg = notification_bg,
            border_width = beautiful.border_width,
            border_color = beautiful.border_color_active,
            shape = helpers.rrect(beautiful.border_radius),
            widget = wibox.container.background
        },
    }
end)