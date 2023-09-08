local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local helpers = require("helpers")

awful.titlebar.enable_tooltip = false

local button_commands = {
    ['close'] = {func = function(c) c:kill() end, tracked_property = nil} ,
    -- ['maximize'] = {func = function(c) c.maximized = not c.maximized; c:raise() end, tracked_property = "maximized"},
    ['maximize'] = {func = function(c) c.maximized = not c.maximized; c:raise() end, tracked_property = nil},
    ['minimize'] = {func = function(c) c.minimized = true end, tracked_property = nil},
    ['sticky'] = {func = function(c)
        -- drop off window at tag when unstickied
        if c.sticky == true then
            c:move_to_tag(mouse.screen.selected_tag)
        end
        c.sticky = not c.sticky
        c:raise()
    end, tracked_property = "sticky"},
    ['ontop'] = {func = function(c) c.ontop = not c.ontop; c:raise() end, tracked_property = "ontop"},
    ['floating'] = {func = function(c) c.floating = not c.floating; c:raise() end, tracked_property = "floating"},
}

text_button = function(c, symbol, color, unfocused_color, hover_color, size, margin, command)
    local button = wibox.widget {
        halign = "center",
        valign = "center",
        font = beautiful.icon,
        markup = helpers.colorize_foreground(symbol, unfocused_color),
        forced_height = size + margin;
        forced_width = size + margin*2,
        widget = wibox.widget.textbox
    }
    
    button:buttons(gears.table.join(
        awful.button({}, 1, function()
            button_commands[command].func(c)
        end)
    ))

    local p = button_commands[command].tracked_property
    if p then
        c:connect_signal("property::"..p, function ()
            button.markup = helpers.colorize_foreground(symbol, c[p] and color or unfocused_color)
        end)
        c:connect_signal("focus", function ()
            button.markup = helpers.colorize_foreground(symbol, c[p] and color or unfocused_color)
        end)
        button:connect_signal("mouse::leave", function ()
            if c == client.focus then
                button.markup = helpers.colorize_foreground(symbol, c[p] and color or unfocused_color)
            else
                button.markup = helpers.colorize_foreground(symbol, unfocused_color)
            end
        end)
    else
        button:connect_signal("mouse::leave", function ()
            if c == client.focus then
                button.markup = helpers.colorize_foreground(symbol, color)
            else
                button.markup = helpers.colorize_foreground(symbol, unfocused_color)
            end
        end)
        c:connect_signal("focus", function ()
            button.markup = helpers.colorize_foreground(symbol, color)
        end)
        c:connect_signal("unfocus", function ()
            button.markup = helpers.colorize_foreground(symbol, unfocused_color)
        end)
    end

    button:connect_signal("mouse::enter", function ()
        button.markup = helpers.colorize_foreground(symbol, hover_color)
    end)

    return button
end

client.connect_signal("request::titlebars", function(c)
    awful.titlebar(c, {font = beautiful.titlebar_font, position = beautiful.titlebar_position, size = beautiful.titlebar_size}):setup{
        {
            {
                helpers.horizontal_pad(12),
                -- text_button(c, "蒶", x.color3, x.color8, x.color11, 13, 4, "sticky"),
                layout = wibox.layout.fixed.horizontal
            },
            {
                -- buttons = keys.titlebar_buttons,
                font = beautiful.titlebar_font,
                halign = "center",
                widget = beautiful.titlebar_title_enabled and awful.titlebar.widget.titlewidget(c) or wibox.widget.textbox("")
            },
            {
                text_button(c, "灁", x.foreground, x.foreground.."80", x.color1, 13, 4, "minimize"),
                text_button(c, "滫", x.foreground, x.foreground.."80", x.color2, 13, 4, "maximize"),
                text_button(c, "濄", x.foreground, x.foreground.."80", x.color3, 13, 4, "close"),
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
end)