local awful = require("awful")
local keygrabber = require("awful.keygrabber")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local helpers = require("helpers")
local schema_helpers = require("schema.schema_helpers")

month_offset = 0

dash = wibox{
    bg = beautiful.ui_cover_bg,
    visible = false,
    ontop = true,
    type = "dock",
    screen = screen.primary
}
awful.placement.maximize(dash, {honor_workarea=true})

awful.screen.connect_for_each_screen(function(s)
    if s == screen.primary then
        s.dash = dash
    else
        s.dash = wibox{
            bg = beautiful.ui_cover_bg,
            visible = false,
            ontop = true,
            type = "splash",
            screen = s
        }
        awful.placement.maximize(s.dash, {honor_workarea=true})
        -- s.dash = wibox{
        --     visible = false,
        --     width = 0,
        --     height = 0
        -- }
    end
end)

-- calendar widget
local styles = {}
styles.month = {
    padding = 10,
    fg_color = x.color8,
    bg_color = x.background.."00",
    border_width = 0
}
styles.normal = {
    
}
styles.focus = {
    fg_color = x.color3,
    bg_color = x.color5.."00",
    markup = function(t) return '<b>' .. t .. '</b>' end
}
styles.header = {
    fg_color = x.foreground,
    bg_color = x.color1,
    markup = function(t) return '<span font_desc="' .. beautiful.font_large .. '"><b>' .. t .. '</b></span>' end
}
styles.weekday = {
    fg_color = x.foreground,
    bg_color = x.color1.."00",
    padding = 2,
    markup = function(t) return '<b>' .. t .. '</b>' end
}

local function decorate_cell(widget, flag, date)
    if flag == 'monthheader' and not styles.monthheader then
        flag = 'header'
    end
    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
        widget:set_markup(props.markup(widget:get_text()))
    end
    -- color change weekends
    local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
    local weekday = tonumber(os.date('%w', os.time(d)))
    local default_fg = x.foreground
    local default_bg = x.color0.."00"
    -- local default_bg = (weekday==0 or weekday==6) and x.color6 or x.color14
    local ret = wibox.widget{
        {
            widget,
            margins = (props.padding or 2) + (props.border_width or 0),
            widget = wibox.container.margin
        },
        shape = props.shape,
        shape_border_color = props.border_color or x.background,
        shape_border_width = props.border_width or 0,
        fg = props.fg_color or default_fg,
        bg = props.bg_color or default_bg,
        widget = wibox.container.background
    }
    return ret
end

local calendar = wibox.widget{
    date = os.date("*t"),
    font = beautiful.font,
    spacing = 7,
    fn_embed = decorate_cell,
    forced_height = dpi(320),
    widget = wibox.widget.calendar.month
}

local prev_month = wibox.widget{
    {
        halign = "right",
        markup = "佀",
        font = beautiful.icon_large,
        forced_width = dpi(30),
        widget = wibox.widget.textbox
    },
    widget = wibox.container.background
}
local current_month = wibox.widget{
    widget = wibox.container.background
}
local next_month = wibox.widget{
    {
        halign = "left",
        markup = "佁",
        font = beautiful.icon_large,
        forced_width = dpi(30),
        widget = wibox.widget.textbox
    },
    widget = wibox.container.background
}
local calendar_widget = wibox.widget{
    {
        calendar,
        forced_height = dpi(320),
        valign = "middle",
        widget = wibox.container.place
    },
    {
        helpers.vertical_pad(58),
        {
            prev_month,
            current_month,
            next_month,
            layout = wibox.layout.align.horizontal
        },
        layout = wibox.layout.fixed.vertical
    },
    forced_height = dpi(450),
    layout = wibox.layout.stack
}
local function update_calendar()
    local d = os.date("*t")
    d.month = d.month+month_offset
    while d.month <= 0 do
        d.month = d.month+12
        d.year = d.year-1
    end
    while d.month > 12 do
        d.month = d.month-12
        d.year = d.year+1
    end
    -- disable day showing if showing a different month
    if month_offset ~= 0 then
        d.day = -1
    end
    calendar.date = d
end
helpers.add_hover_cursor(prev_month, "hand1")
prev_month:buttons({
    awful.button({}, 1, function()
        month_offset = month_offset-1
        update_calendar()
    end)
})
helpers.add_hover_cursor(current_month, "hand1")
current_month:buttons({
    awful.button({}, 1, function()
        month_offset = 0
        update_calendar()
    end)
})
helpers.add_hover_cursor(next_month, "hand1")
next_month:buttons({
    awful.button({}, 1, function()
        month_offset = month_offset+1
        update_calendar()
    end)
})

-- battery widget
local battery_arc = wibox.widget{
    start_angle = 1.5 * math.pi,
    min_value = 0,
    max_value = 100,
    value = 50,
    thickness = dpi(12),
    forced_width = dpi(90),
    forced_height = dpi(90),
    rounded_edge = true,
    bg = beautiful.battery_bar_active_background_color,
    colors = {beautiful.battery_bar_active_color},
    widget = wibox.container.arcchart
}
local battery_hover_text_value = wibox.widget{
    halign = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local battery_hover_text_wrapper = wibox.container.background(battery_hover_text_value)

local battery_hover_charging_text_value = wibox.widget{
    halign = "center",
    valign = "center",
    font = beautiful.font_small,
    widget = wibox.widget.textbox
}

local battery_hover_text = wibox.widget{
    battery_hover_text_wrapper,
    battery_hover_charging_text_value,
    spacing = dpi(2),
    visible = false,
    layout = wibox.layout.fixed.vertical
}

awesome.connect_signal("meow::battery", function(value)
    battery_arc.value = value
    battery_hover_text_value.markup = tostring(value).."%"
end)

local battery_icon = wibox.widget{
    halign = "center",
    valign = "center",
    font = beautiful.icon_extra_large,
    markup = helpers.colorize_foreground("戊", beautiful.battery_bar_active_color),
    widget = wibox.widget.textbox()
}

awesome.connect_signal("meow::battery_charging", function(plugged)
    if plugged then
        battery_hover_charging_text_value.markup = "charging"
        battery_arc.bg = beautiful.battery_bar_charging_background_color
        battery_arc.colors = {beautiful.battery_bar_charging_color}
        battery_icon.markup = helpers.colorize_foreground("戊", beautiful.battery_bar_charging_color)
        battery_hover_text_wrapper.fg = beautiful.battery_bar_charging_color
    else
        battery_hover_charging_text_value.markup = ""
        battery_arc.bg = beautiful.battery_bar_active_background_color
        battery_arc.colors = {beautiful.battery_bar_active_color}
        battery_icon.markup = helpers.colorize_foreground("戊", beautiful.battery_bar_active_color)
        battery_hover_text_wrapper.fg = x.foreground
    end
end)

local battery_widget = wibox.widget{
    {
        nil,
        battery_hover_text,
        expand = "none",
        layout = wibox.layout.align.vertical
    },
    battery_icon,
    battery_arc,
    top_only = false,
    layout = wibox.layout.stack
}

local host_text = wibox.widget{
    halign = "center",
    valign = "center",
    font = beautiful.font_mono,
    widget = wibox.widget.textbox
}
awful.spawn.easy_async_with_shell("hostname", function(stdout)
    -- remove the newline at the end of stdout
    stdout = stdout:gsub('^%s*(.-)%s*$', '%1')
    host_text.markup = helpers.colorize_foreground("@"..stdout, x.color8)
end)

local user_widget = wibox.widget{
    {
        {
            resize = true,
            upscale = true,
            downscale = true,
            image = user.profile,
            widget = wibox.widget.imagebox
        },
        forced_width = dpi(128),
        forced_height = dpi(128),
        border_width = beautiful.ui_border_width,
        border_color = beautiful.ui_border_color,
        shape = helpers.rrect(beautiful.ui_radius),
        -- shape = helpers.rrect(dpi(3)),
        widget = wibox.container.background
    },
    helpers.vertical_pad(dpi(14)),
    {
        halign = "center",
        valign = "center",
        font = beautiful.font_large,
        -- markup = helpers.colorize_foreground(os.getenv("USER"), x.foreground),
        markup = os.getenv("USER"),
        widget = wibox.widget.textbox
    },
    helpers.vertical_pad(dpi(4)),
    host_text,
    layout = wibox.layout.fixed.vertical
}

-- all about bars!
-- helper function for applying a default style to the progress bars
local function format_progress_bar(bar, bar_icon)
    bar.forced_width = dpi(180)
    bar.forced_height = dpi(14)
    bar.shape = gears.shape.rounded_bar
    bar.bar_shape = gears.shape.rounded_bar
    if bar.handle_shape then
        bar.handle_shape = gears.shape.rounded_bar
        bar.handle_width = dpi(14)
        bar.bar_height = dpi(14)
        bar.slider_bar_height = dpi(14)
    end
    local sensor_value = wibox.widget{
        forced_height = dpi(14),
        halign = "center",
        valign = "center",
        font = beautiful.font_small,
        markup = "",
        widget = wibox.widget.textbox
    }
    local w = wibox.widget{
        {
            forced_height = dpi(20),
            forced_width = dpi(20),
            halign = "center",
            valign = "center",
            font = beautiful.icon,
            widget = bar_icon
        },
        {
            {
                nil,
                bar,
                sensor_value,
                layout = wibox.layout.stack,
            },
            widget = wibox.container.place
        },
        nil,
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal,
    }
    w:connect_signal("mouse::enter", function ()
        sensor_value.markup = bar.value..'/'..(bar.max_value or bar.maximum)
    end)
    if bar.maximum then
        bar:connect_signal("property::value", function(_, new_value)
            if sensor_value.markup ~= "" then
                sensor_value.markup = new_value..'/'..bar.maximum
            end
        end)
    end
    w:connect_signal("mouse::leave", function ()
        sensor_value.markup = ""
    end)
    return w
end

-- slider info widgets
local volume_bar = wibox.widget{
    maximum = 100,
    value = 50,
    bar_height = dpi(35),
    forced_width  = dpi(200),
    shape = gears.shape.rounded_bar,
    bar_shape = gears.shape.rounded_bar,
    handle_shape = gears.shape.circle,
    handle_color = beautiful.volume_bar_active_color,
    handle_width = dpi(20),
    bar_active_color = beautiful.volume_bar_active_color,
    bar_color = beautiful.volume_bar_active_background_color,
    widget = wibox.widget.slider
}
local volume_icon = wibox.widget{
    widget = wibox.widget.textbox
}
awesome.connect_signal("meow::volume", function(percentage, muted)
    local bg_color
    if muted then
        fill_color = beautiful.volume_bar_muted_color
        bg_color = beautiful.volume_bar_muted_background_color
    else
        fill_color = beautiful.volume_bar_active_color
        bg_color = beautiful.volume_bar_active_background_color
    end
    volume_bar.value = percentage
    volume_bar.handle_color = fill_color
    volume_bar.bar_active_color = fill_color
    volume_bar.background_color = bg_color
    volume_icon.markup = helpers.volume_icon(percentage, muted)
end)
helpers.add_hover_cursor(volume_icon, "hand1")
volume_icon:buttons({
    awful.button({}, 1, function()
        helpers.volume_control(0)
    end)
})
helpers.add_hover_cursor(volume_bar, "hand1")
volume_bar:connect_signal("property::value", function(_, new_value)
    awful.spawn("pactl set-sink-volume 0 ".. new_value .. "%")
end)

local brightness_bar = wibox.widget{
    maximum = 100,
    value = 50,
    bar_height = dpi(35),
    forced_width  = dpi(200),
    shape = gears.shape.rounded_bar,
    bar_shape = gears.shape.rounded_bar,
    handle_shape = gears.shape.circle,
    handle_color = beautiful.brightness_bar_active_color,
    handle_width = dpi(20),
    bar_active_color = beautiful.brightness_bar_active_color,
    bar_color = beautiful.brightness_bar_background_color,
    widget = wibox.widget.slider
}
local brightness_icon = wibox.widget{
    halign = "center",
    valign = "center",
    widget = wibox.widget.textbox
}
awesome.connect_signal("meow::brightness", function(percentage)
    brightness_bar.value = percentage
    brightness_icon.markup = helpers.brightness_icon(percentage)
end)
helpers.add_hover_cursor(brightness_bar, "hand1")
brightness_bar:connect_signal("property::value", function(_, new_value)
    awful.spawn("light -S ".. new_value .. "%")
end)

local volume = format_progress_bar(volume_bar, volume_icon)
local brightness = format_progress_bar(brightness_bar, brightness_icon)
local slider_widget = wibox.widget{
    volume,
    brightness,
    spacing = 15,
    layout = wibox.layout.flex.vertical
}

-- info widgets
local cpu_bar = wibox.widget{
    max_value = 100,
    value = 50,
    shape = gears.shape.rounded_bar,
    color = beautiful.cpu_bar_active_color,
    background_color = beautiful.cpu_bar_background_color,
    widget = wibox.widget.progressbar,
}
awesome.connect_signal("meow::cpu", function(percentage)
    cpu_bar.value = tonumber(percentage)
end)
local cpu_icon = wibox.widget{
    markup = "蔽",
    widget = wibox.widget.textbox
}
local cpu = format_progress_bar(cpu_bar, cpu_icon)
local ram_bar = wibox.widget{
    max_value = 80,
    value = 20,
    shape = gears.shape.rounded_bar,
    color = beautiful.ram_bar_active_color,
    background_color = beautiful.ram_bar_background_color,
    widget = wibox.widget.progressbar,
}
awesome.connect_signal("meow::ram", function(used, total)
    ram_bar.value = helpers.round(used/1024, 1)
    ram_bar.max_value = helpers.round(total/1024, 1)
end)
local ram_icon = wibox.widget{
    markup = "薟",
    widget = wibox.widget.textbox
}
local ram = format_progress_bar(ram_bar, ram_icon)
local temperature_bar = wibox.widget{
    max_value = 80,
    min_value = 20,
    value = 50,
    shape = gears.shape.rounded_bar,
    color = beautiful.temperature_bar_active_color,
    background_color = beautiful.temperature_bar_background_color,
    widget = wibox.widget.progressbar
}
awesome.connect_signal("meow::temperature", function(value)
    temperature_bar.value = value
end)
local temperature_icon = wibox.widget{
    markup = "唖",
    widget = wibox.widget.textbox
}
local temperature = format_progress_bar(temperature_bar, temperature_icon)

local info_widget = wibox.widget{
    cpu,
    ram,
    temperature,
    spacing = 15,
    layout = wibox.layout.fixed.vertical
}

-- mpd widget
loop_icon = wibox.widget{
    halign = "center",
    valign = "center",
    markup = "剕",
    font = beautiful.icon_large,
    widget = wibox.widget.textbox
}
loop_button = wibox.widget{
    loop_icon,
    widget = wibox.container.background
}
prev_button = wibox.widget{
    {
        halign = "center",
        valign = "center",
        markup = "劭",
        font = beautiful.icon_large,
        widget = wibox.widget.textbox
    },
    widget = wibox.container.background
}
play_icon = wibox.widget{
    halign = "center",
    valign = "center",
    markup = "",
    font = beautiful.icon_extra_large,
    widget = wibox.widget.textbox
}
play_button = wibox.widget{
    {
        valign = "top",
        play_icon,
        widget = wibox.container.place
    },
    forced_height = dpi(55),
    forced_width = dpi(30),
    widget = wibox.container.background
}
next_button = wibox.widget{
    {
        halign = "center",
        valign = "center",
        markup = "劬",
        font = beautiful.icon_large,
        widget = wibox.widget.textbox
    },
    widget = wibox.container.background
}
random_icon = wibox.widget{
    halign = "center",
    valign = "center",
    markup = "劜",
    font = beautiful.icon_large,
    widget = wibox.widget.textbox
}
random_button = wibox.widget{
    random_icon,
    widget = wibox.container.background
}
helpers.add_hover_cursor(loop_button, "hand1")
loop_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc repeat")
    end)
})
helpers.add_hover_cursor(play_button, "hand1")
play_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc toggle")
    end)
})
helpers.add_hover_cursor(prev_button, "hand1")
prev_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc prev")
    end)
})
helpers.add_hover_cursor(next_button, "hand1")
next_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc next")
    end)
})
helpers.add_hover_cursor(random_button, "hand1")
random_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc random")
    end)
})

local album_art = wibox.widget{
    forced_width = 120,
    forced_height = 120,
    widget = wibox.widget.imagebox
}
local mpd_title = wibox.widget{
    markup = "---------",
    halign = "center",
    valign = "center",
    font = beautiful.font,
    forced_width = dpi(100),
    forced_height = dpi(50),
    widget = wibox.widget.textbox
}
local mpd_artist = wibox.widget{
    markup = helpers.colorize_foreground("---------", x.color8),
    halign = "center",
    valign = "center",
    font = beautiful.font_small,
    widget = wibox.widget.textbox
}

awesome.connect_signal("meow::mpd", function(artist, title, status, albumart)
    if status == true then
        play_icon.markup = "刉"
    else
        play_icon.markup = "凣"
    end

    -- escape & in title and artist
    title = string.gsub(title, "&", "&amp;")
    artist = string.gsub(artist, "&", "&amp;")

    mpd_title.markup = title
    mpd_artist.markup = helpers.colorize_foreground(artist, x.foreground)

    album_art.image = albumart
end)

awesome.connect_signal("meow::mpd_options", function(loop, random)
    if loop == true then
        loop_button.fg = "#ffffff"
    else
        loop_button.fg = x.color0
    end
    if random == true then
        random_button.fg = "#ffffff"
    else
        random_button.fg = x.color0
    end
end)

mpd_widget = wibox.widget{
    {
        {
            album_art,
            forced_width = dpi(128),
            forced_height = dpi(128),
            border_width = beautiful.ui_border_width,
            border_color = beautiful.ui_border_color,
            shape = helpers.rrect(beautiful.ui_radius),
            -- shape = helpers.rrect(dpi(3)),
            widget = wibox.container.background
        },
        forced_width = dpi(350),
        widget = wibox.container.place
    },
    {
        {
            loop_button,
            prev_button,
            play_button,
            next_button,
            random_button,
            spacing = dpi(15),
            layout = wibox.layout.fixed.horizontal
        },
        forced_height = dpi(60),
        widget = wibox.container.place
    },
    {
        mpd_title,
        mpd_artist,
        forced_width = dpi(100),
        layout = wibox.layout.fixed.vertical
    },
    forced_width = dpi(200),
    layout = wibox.layout.fixed.vertical
}


-- create boxes
local calendar_box = schema_helpers.package(calendar_widget, dpi(350), dpi(450), beautiful.ui_bg, beautiful.useless_gap, "cal")
local slider_box = schema_helpers.package(slider_widget, dpi(350), dpi(130), beautiful.ui_bg, beautiful.useless_gap, "sliders")
local battery_box = schema_helpers.package(battery_widget, dpi(350), dpi(200), beautiful.ui_bg, beautiful.useless_gap, "bat")
battery_box:connect_signal("mouse::enter", function ()
    battery_icon.visible = false
    battery_hover_text.visible = true
end)
battery_box:connect_signal("mouse::leave", function ()
    battery_icon.visible = true
    battery_hover_text.visible = false
end)
local mpd_box = schema_helpers.package(mpd_widget, dpi(350), dpi(380), beautiful.ui_bg, beautiful.useless_gap, "mpd")
local user_box = schema_helpers.package(user_widget, dpi(300), dpi(410), beautiful.ui_bg, beautiful.useless_gap, "fetch")
local info_box = schema_helpers.package(info_widget, dpi(300), dpi(170), beautiful.ui_bg, beautiful.useless_gap, "htop")

-- put boxes into dashboard
dash:setup{
    { -- column container
        {
            user_box,
            info_box,
            layout = wibox.layout.fixed.vertical
        },
        {
            battery_box,
            mpd_box,
            layout = wibox.layout.fixed.vertical
        },
        {
            calendar_box,
            slider_box,
            layout = wibox.layout.fixed.vertical
        },
        layout = wibox.layout.fixed.horizontal
    },
    halign = "center",
    valign = "center",
    widget = wibox.container.place
}

function dash_toggle()
    for s in screen do
        s.dash.visible = not s.dash.visible
    end
    update_calendar()
end

dash.dash_grabber = awful.keygrabber{
    stop_key = {"Escape", "q", "F1"},
    stop_event = "press",
    start_callback = dash_toggle,
    stop_callback = dash_toggle,
}

return dash