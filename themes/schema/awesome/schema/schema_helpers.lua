local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local helpers = require("helpers")
local decorations = require("schema.decorations")

schema_helpers = {}

local text_button = function(symbol, color, hover_color, size, margin)
    local button = wibox.widget{
        halign = "center",
        valign = "center",
        font = beautiful.icon,
        markup = helpers.colorize_foreground(symbol, color),
        forced_height = size + margin;
        forced_width = size + margin*2,
        widget = wibox.widget.textbox
    }
    button:connect_signal("mouse::leave", function()
        button.markup = helpers.colorize_foreground(symbol, color)
    end)
    button:connect_signal("mouse::enter", function()
        button.markup = helpers.colorize_foreground(symbol, hover_color)
    end)
    return button
end

schema_helpers.package = function(w, width, height, bg, gap, title)
    local mock_deco = wibox.widget{
        {
            {
                helpers.horizontal_pad(15),
                {
                    font = beautiful.titlebar_font,
                    halign = "center",
                    markup = title,
                    widget = wibox.widget.textbox
                },
                layout = wibox.layout.fixed.horizontal
            },
            nil,
            {
                text_button("灁", x.foreground, x.color1, 13, 4),
                text_button("滫", x.foreground, x.color2, 13, 4),
                text_button("濄", x.foreground, x.color3, 13, 4),
                helpers.horizontal_pad(6),
                layout = wibox.layout.fixed.horizontal
            },
            forced_height = beautiful.titlebar_size - beautiful.border_width,
            layout = wibox.layout.align.horizontal
        },
        {
            forced_height = beautiful.border_width,
            bg = beautiful.border_color,
            widget = wibox.container.background
        },
        layout = wibox.layout.fixed.vertical
    }

    local boxed = wibox.widget{
        {
            {
                mock_deco,
                {
                    w,
                    halign = "center",
                    valign = "center",
                    forced_height = height - beautiful.titlebar_size,
                    widget = wibox.container.place,
                },
                layout = wibox.layout.fixed.vertical
            },
            border_color = beautiful.ui_border_color,
            border_width = beautiful.ui_border_width,
            bg = bg,
            forced_height = height,
            forced_width = width,
            shape = helpers.rrect(beautiful.ui_radius),
            widget = wibox.container.background
        },
        margins = gap,
        color = "#00000000",
        widget = wibox.container.margin
    }
    return boxed
end

return schema_helpers