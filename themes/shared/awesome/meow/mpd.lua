-- provides:
-- meow::mpd
--      artist (string)
--      title (string)
--      paused (boolean)
--      albumart (string)
-- meow::mpd_volume
--      value (integer from 0 to 100)
-- meow::mpd_options
--      loop (boolean)
--      random (boolean)

local awful = require("awful")
local helpers = require("helpers")

-- function for forwarding song and player information
local function mpd_status()
    awful.spawn.easy_async_with_shell("sh -c 'mpc -f ARTIST@%artist%@TITLE@%title%@FILE@%file%@ALBUM@%album%@E'", function(stdout)
        local artist = stdout:match('^ARTIST@(.*)@TITLE')
        local title = stdout:match('@TITLE@(.*)@FILE')
        local album = stdout:match('@ALBUM@(.*)@E')
        local status = stdout:match('\n%[(.*)%]')

        if not artist or artist == "" then
            artist = "N/A"
        end
        if not album or album == "" then
            album = "N/A"
        end
        if not title or title == "" then
            title = stdout:match('@FILE@(.*)@')
            if not title or title == "" then
                title = "N/A"
            end
        end
        local paused = true
        if status == "playing" then
            paused = false
        end

        awful.spawn.easy_async_with_shell(bin_dir.."/songinfo", function(out)
            awesome.emit_signal("meow::mpd", artist, title, paused, out:gsub("\n[^\n]*(\n?)$", "%1"))
        end)
    end)
end

-- function for forwarding volume information
local function mpd_volume()
    awful.spawn.easy_async_with_shell("mpc volume | awk '{print substr($2, 1, length($2)-1)}'", function(stdout)
        awesome.emit_signal("meow::mpd_volume", tonumber(stdout))
    end
    )
end

-- function for forwarding options information
local function mpd_options()
    awful.spawn.easy_async_with_shell("mpc | tail -1", function(stdout)
        local loop = stdout:match('repeat: (.*)')
        local random = stdout:match('random: (.*)')
        awesome.emit_signal("meow::mpd_options", loop:sub(1, 2) == "on", random:sub(1, 2) == "on")
    end)
end

helpers.run_and_watch(mpd_status, "mpc idleloop player")
helpers.run_and_watch(mpd_volume, "mpc idleloop mixer")
helpers.run_and_watch(mpd_options, "mpc idleloop options")