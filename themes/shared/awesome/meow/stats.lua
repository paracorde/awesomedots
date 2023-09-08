-- provides
-- meow::brightness
--      percentage (integer)
-- meow::volume
--      percentage (integer)
--      muted (boolean)
-- meow::cpu
--      percentage (float)
-- meow::ram
--      used (integer)
--      total (integer)
-- meow::temperature
--      temperature (float)
-- meow::battery
--      percentage (integer)
-- meow::battery_charging
--      charging (boolean)


local awful = require("awful")
local helpers = require("helpers")

-- function for getting brightness
local brightness = function()
    awful.spawn.with_line_callback("light", {
        stdout = function(line)
            percentage = math.floor(tonumber(line))
            awesome.emit_signal("meow::brightness", percentage)
        end
    })
end

-- function for getting volume and muted status
local volume_old = -1
local muted_old = -1
local volume = function()
    -- get volume info for active sink (which has a star)
    awful.spawn.easy_async_with_shell("pactl get-sink-mute @DEFAULT_SINK@", function(stdout)
        local muted = stdout:match("yes")
        awful.spawn.easy_async_with_shell("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
            local volume = tonumber(stdout:match('(%d+)%% /'))
            local muted_int = muted and 1 or 0
            -- send signal if there was a change
            if volume ~= volume_old or muted_int ~= muted_old then
                awesome.emit_signal("meow::volume", volume, muted)
                volume_old = volume
                muted_old = muted_int
            end
        end)
    end)
end

helpers.run_and_watch(brightness, "while (inotifywait -e modify /sys/class/backlight/?*/brightness -qq) do echo; done", "inotifywait -e modify /sys/class/backlight")
helpers.run_and_watch(volume, [[LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink #\"]], "pactl subscribe")

 -- simpler stat scripts that run on a timer
local cpu_script = [[sh -c "mpstat 2 1 | awk '$3 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $3 ~ /all/ { print 100 - $field }'"]]
awful.widget.watch(cpu_script, 10, function(widget, stdout)
    awesome.emit_signal("meow::cpu", tonumber(stdout))
end)

-- local ram_script = [[bash -c "free -m | sed -n '2p' | awk '{printf \"%d@@%d@\", $7, $2}'"]]
local ram_script = [[sh -c "free -m | grep 'Mem:' | awk '{printf \"%d@@%d@\", $7, $2}'"]]
awful.widget.watch(ram_script, 5, function(widget, stdout)
    local available = tonumber(stdout:match('(.*)@@'))
    local total = tonumber(stdout:match('@@(.*)@'))
    local used = total - available
    awesome.emit_signal("meow::ram", used, total)
end)

local temperature_script = [[sh -c "sensors | grep Composite | awk '{print $2}' | cut -c 2-5"]]
awful.widget.watch(temperature_script, 5, function(widget, stdout)
    awesome.emit_signal("meow::temperature", tonumber(stdout))
end)

local battery_script = [[sh -c "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'percentage' | awk '{print $2}'"]]
awful.widget.watch(battery_script, 5, function(widget, stdout)
    awesome.emit_signal("meow::battery", string.sub(stdout, 0, #stdout-2))
end)

local charging_script = [[sh -c "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'state'"]]
awful.widget.watch(charging_script, 5, function(widget, stdout)
    local charging = true
    if stdout:match("discharging") then
        charging = false
    end
    awesome.emit_signal("meow::battery_charging", charging)
end)
