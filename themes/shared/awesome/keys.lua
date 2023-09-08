local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local helpers = require("helpers")

local keys = {}

-- keys.desktop_buttons = gears.table.join(
--     -- left click - dismiss everything
--     awful.button({}, 1, function ()
--         awesome.emit_signal("squidget::dismiss")
--         naughty.destroy_all_notifications()
--     end),

--     -- right click - show app drawer
--     awful.button({}, 3, function () mymainmenu:toggle() end),
--     awful.button({}, 3, function ()
--         if app_drawer_show then
--             app_drawer_show()
--         end
--     end),

--     -- middle button - toggle dashboard
--     awful.button({}, 2, function ()
--         if dash_show then
--             dash_show()
--         end
--     end),

--     -- scrolling - switch tags
--     awful.button({}, 4, awful.tag.viewprev),
--     awful.button({}, 5, awful.tag.viewnext),
-- )

-- resize helper function
local floating_resize_amount = dpi(20)
local tiling_resize_factor = 0.05
function resize_window(c, direction)
    if c and c.floating then
        if direction == "up" then
            c:relative_move(0, 0, 0, -floating_resize_amount)
        elseif direction == "down" then
            c:relative_move(0, 0, 0, floating_resize_amount)
        elseif direction == "left" then
            c:relative_move(0,  0, -floating_resize_amount, 0)
        elseif direction == "right" then
            c:relative_move(0, 0, floating_resize_amount, 0)
        end
    elseif awful.layout.get(mouse.screen) ~= awful.layout.suit.floating then
        if direction == "up" then
            awful.client.incwfact(-tiling_resize_factor)
        elseif direction == "down" then
            awful.client.incwfact( tiling_resize_factor)
        elseif direction == "left" then
            awful.tag.incmwfact(-tiling_resize_factor)
        elseif direction == "right" then
            awful.tag.incmwfact(tiling_resize_factor)
        end
    end
end

-- window moving helper functions
function move_to_edge(c, direction)
    local old = c:geometry()
    local new = awful.placement[direction_translate[direction]](c, {honor_padding = true, honor_workarea = true, margins = beautiful.useless_gap * 2, pretend = true})
    if direction == "up" or direction == "down" then
        c:geometry({x = old.x, y = new.y})
    else
        c:geometry({x = new.x, y = old.y})
    end
end
function move_client(c, direction)
    if c.floating or (awful.layout.get(mouse.screen) == awful.layout.suit.floating) then
        move_to_edge(c, direction)
    elseif awful.layout.get(mouse.screen) == awful.layout.suit.max then
        if direction == "up" or direction == "left" then
            awful.client.swap.byidx(-1, c)
        elseif direction == "down" or direction == "right" then
            awful.client.swap.byidx(1, c)
        end
    else
        awful.client.swap.bydirection(direction, c, nil)
    end
end

-- global key bindings
keys.global_keys = gears.table.join(
    -- focus client through wasd or direction keys
    awful.key({"Mod4"}, "Up", function()
        awful.client.focus.bydirection("up")
    end, {description = "focus up", group = "client"}),
    awful.key({"Mod4"}, "Left", function()
        awful.client.focus.bydirection("left")
    end, {description = "focus left", group = "client"}),
    awful.key({"Mod4"}, "Down", function()
        awful.client.focus.bydirection("down")
    end, {description = "focus down", group = "client"}),
    awful.key({"Mod4"}, "Right", function()
        awful.client.focus.bydirection("right")
    end, {description = "focus right", group = "client"}),

    -- window switcher
    awful.key({"Mod4"}, "Tab", function ()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
        -- window_switcher_show(awful.screen.focused())
    end, {description = "activate window switcher", group = "client"}),
    
    -- resize windows
    awful.key({"Mod4", "Control"}, "Down", function (c)
        resize_window(client.focus, "down")
    end),
    awful.key({"Mod4", "Control"}, "Up", function (c)
        resize_window(client.focus, "up")
    end),
    awful.key({"Mod4", "Control"}, "Left", function (c)
        resize_window(client.focus, "left")
    end),
    awful.key({"Mod4", "Control"}, "Right", function (c)
        resize_window(client.focus, "right")
    end),

    -- reload awesome
    awful.key({"Mod4", "Shift"}, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),    

    -- run rofi as a launcher
    -- awful.key({"Control", "Shift"}, "space", function()
    --     awful.spawn.with_shell("rofi -matching fuzzy -show combi")
    -- end, {description = "rofi launcher", group = "launcher"}),

    -- layout max, tiling, and floating
    awful.key({"Mod4"}, "m", function()
        awful.layout.set(awful.layout.suit.max)
    end, {description = "set max layout", group = "tag"}),
    awful.key({"Mod4"}, "t", function()
        awful.layout.set(awful.layout.suit.tile)
    end, {description = "set tiling layout", group = "tag"}),
    awful.key({"Mod4"}, "s", function()
        awful.layout.set(awful.layout.suit.floating)
    end, {description = "set floating layout", group = "tag"}),
    -- spawn terminal
    awful.key({"Mod4"}, "Return", function ()
        awful.spawn(user.term)
    end, {description = "open a terminal", group = "launcher"}),

    -- for some reason, Fn isn't a modifier. instead, these also get activated with the appropriate Fn+F# combo, which is convenient enough
    -- brightness controls
    awful.key({}, "XF86MonBrightnessDown", function()
        helpers.brightness_control(-10)
    end, {description = "decrease brightness", group = "brightness"}),
    awful.key({}, "XF86MonBrightnessUp", function()
        helpers.brightness_control(10)
    end, {description = "increase brightness", group = "brightness"}),

    -- volume controls
    awful.key({}, "XF86AudioMute", function()
        helpers.volume_control(0)
    end, {description = "mute/unmute volume", group = "volume"}),
    awful.key({}, "XF86AudioLowerVolume", function()
        helpers.volume_control(-5)
    end, {description = "lower volume", group = "volume"}),
    awful.key({}, "XF86AudioRaiseVolume", function()
        helpers.volume_control(5)
    end, {description = "raise volume", group = "volume"}),

    -- screenshot
    awful.key({"Mod4", "Shift"}, "c", function()
        awful.spawn.easy_async_with_shell("maim -u -s -l -c 0.4,0.4,0.5,0.8 -m 5 | xclip -selection clipboard -t image/png", function(_, _, _, exitcode)
            if exitcode == 0 then
                naughty.notification({
                    title = "Screenshot",
                    message = "Screenshot copied!",
                    app_name = "screenshot",
                    timeout = 3,
                })
            end
        end)
    end, {description = "screenshot and select", group = "screen"}),
    awful.key({"Mod4"}, "c", function()
        local t = os.date("%Y-%m-%d.%H:%M:%S")
        local s_dest = user.dirs.screenshots.."/"..t..".png"
        awful.spawn.easy_async_with_shell("maim -u -s -l -c 0.4,0.4,0.5,0.8 -m 5 "..s_dest, function(_, _, _, exitcode)
            if exitcode == 0 then
                naughty.notification({
                    title = "Screenshot",
                    message = "Screenshot saved at "..s_dest.."!",
                    app_name = "screenshot",
                    timeout = 3,
                })
            end
        end)
    end, {description = "screenshot and save", group = "screen"}),
    awful.key({"Mod4"}, "r", function()
        local t = os.date("%Y-%m-%d.%H:%M:%S")
        local r_dest = user.dirs.videos.."/"..t..".ogv"
        awesome.emit_signal("keys::recording")
        awful.spawn.easy_async_with_shell("recordmydesktop --no-sound --on-the-fly-encoding -o"..r_dest, function()
            naughty.notification({
                title = "Recording",
                message = "Recording saved at "..r_dest.."!",
                app_name = "screenshot",
                timeout = 3,
            })
        end)
    end, {description = "record desktop", group = "screen"})
)

-- client buttons
keys.client_buttons = gears.table.join(
    awful.button({}, 1, function (c) client.focus = c end),
    awful.button({"Mod4"}, 1, awful.mouse.client.move),
    -- awful.button({"Mod4"}, 2, function (c) c:kill() end),
    awful.button({"Mod4"}, 3, function(c)
        client.focus = c
        awful.mouse.client.resize(c)
        -- awful.mouse.resize(c, nil, {jump_to_corner=true})
    end)

    -- -- scroll to change opacity
    -- awful.button({"Mod4"}, 4, function(c)
    --     c.opacity = c.opacity + 0.1
    -- end),
    -- awful.button({"Mod4"}, 5, function(c)
    --     c.opacity = c.opacity - 0.1
    -- end)
)

local ntags = 10
for i = 1, ntags do
    keys.global_keys = gears.table.join(keys.global_keys,
        -- View tag only.
        awful.key({"Mod4"}, "#" .. i + 9, function ()
            local tag = mouse.screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, {description = "view tag #"..i, group = "tag"}),

        -- Toggle tag display.
        awful.key({"Mod4", "Control"}, "#" .. i + 9, function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, {description = "toggle tag #" .. i, group = "tag"}),

        -- Move client to tag.
        awful.key({"Mod4", "Shift"}, "#" .. i + 9, function ()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #"..i, group = "tag"}),

        -- Move all visible clients to tag and focus that tag
        awful.key({"Mod4", "Mod1"}, "#" .. i + 9, function ()
            local tag = client.focus.screen.tags[i]
            local clients = awful.screen.focused().clients
            if tag then
                for _, c in pairs(clients) do
                    c:move_to_tag(tag)
                end
                tag:view_only()
            end
        end, {description = "move all visible clients to tag #"..i, group = "tag"}),
        
        -- Toggle tag on focused client.
        awful.key({"Mod4", "Control", "Shift"}, "#" .. i + 9, function ()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end


-- client key bindings
keys.client_keys = gears.table.join(
    -- move client
    awful.key({"Mod4", "Shift"}, "Down", function (c)
        move_client(c, "down")
    end),
    awful.key({"Mod4", "Shift"}, "Up", function (c)
        move_client(c, "up")
    end),
    awful.key({"Mod4", "Shift"}, "Left", function (c)
        move_client(c, "left")
    end),
    awful.key({"Mod4", "Shift"}, "Right", function (c)
        move_client(c, "right")
    end),

    -- toggle fullscreen
    awful.key({"Mod4"}, "=", function (c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, {description = "toggle fullscreen", group = "client"}),

    -- close client
    awful.key({"Mod4", "Shift"}, "q", function (c)
        c:kill()
    end, {description = "close", group = "client"}),
    awful.key({"Mod1"}, "F4", function (c)
        c:kill()
    end, {description = "close", group = "client"}),

    -- toggle floating
    awful.key({"Mod4"}, "space", function(c)
        if not (awful.layout.get(mouse.screen) == awful.layout.suit.floating) then
            awful.client.floating.toggle()
        end
    end, {description = "toggle floating", group = "client"})
)

-- root.keys(keys.global_keys)

return keys
