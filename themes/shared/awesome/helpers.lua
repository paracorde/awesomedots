local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local helpers = {}

helpers.colorize_foreground = function(text, foreground)
    return "<span foreground='"..foreground.."'>"..text.."</span>"
end

helpers.colorize_full = function(text, foreground, background)
    return "<span foreground='"..foreground.."' background='"..background"'>"..text.."</span>"
end

helpers.volume_control = function(step)
    local cmd
    -- mute if 0
    if step == 0 then
        cmd = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    else
        sign = step > 0 and "+" or ""
        cmd = "pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ "..sign..tostring(step).."%"
    end
    awful.spawn.with_shell(cmd)
end

helpers.brightness_control = function(step)
    local cmd
    sign = step > 0 and " -A " or " -U "
    cmd = "light"..sign..tostring(math.abs(step))
    awful.spawn.with_shell(cmd)
end

helpers.vertical_pad = function(height)
    return wibox.widget{
        forced_height = dpi(height),
        layout = wibox.layout.fixed.vertical
    }
end

helpers.horizontal_pad = function(width)
    return wibox.widget{
        forced_width = dpi(width),
        layout = wibox.layout.fixed.horizontal
    }
end

helpers.rrect = function(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

helpers.prrect = function(radius, tl, tr, br, bl)
    return function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, tl, tr, br, bl, radius)
    end
end

-- helper function for meow module to initialize variables and then watch for changes
helpers.run_and_watch = function(emit_function, idleloop, idleloop_name)
    -- call once to initialize
    emit_function()

    -- kill existing script (from previous awesome instances), then launch the idleloop script
    awful.spawn.easy_async_with_shell("ps x | grep \""..(idleloop_name or idleloop).."\" | grep -v grep | awk '{print $1}' | xargs kill", function()
        awful.spawn.with_line_callback("bash -c \""..idleloop.."\"", {stdout = function()
            emit_function()
        end
    })
    end)
end

helpers.brightness_icon = function(percentage)
    local icon
    if percentage <= 40 then
        icon = "痴"
    else
        icon = "痳"
    end
    return icon
end

helpers.volume_icon = function(percentage, muted)
    local icon
    if muted then
        icon = "粌"
    else
        if percentage <= 15 then
            icon = "窺"
        elseif percentage <= 30 then
            icon = "窻"
        elseif percentage <= 75 then
            icon = "罷"
        else
            icon = "窼"
        end
    end
    return icon
end

helpers.package = function(w, width, height, bg, gap)
    local boxed = wibox.widget{
        {
            {
                w,
                halign = "center",
                valign = "center",
                widget = wibox.container.place,
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

-- rounds to a specified accuracy
helpers.round = function(number, decimals)
    local power = 10 ^ decimals
    return math.floor(number * power) / power
end

-- adds a hover cursor to a widget
helpers.add_hover_cursor = function(w, hover_cursor)
    local original_cursor = "left_ptr"

    w:connect_signal("mouse::enter", function ()
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = hover_cursor
        end
    end)

    w:connect_signal("mouse::leave", function ()
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = original_cursor
        end
    end)
end

return helpers
