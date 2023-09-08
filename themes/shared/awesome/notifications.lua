local beautiful = require("beautiful")
local naughty = require("naughty")

local helpers = require("helpers")

local notifications = {}

-- timeouts
naughty.config.defaults.timeout = 5
naughty.config.presets.low.timeout = 2
naughty.config.presets.critical.timeout = 12

-- smarter notify command that will create or store a notification
notifications.notify = function(args, notif)
    local n = notif
    if n and not n._private.is_destroyed and not n.is_expired then
        notif.title = args.title or notif.title
        notif.message = args.message or notif.message
        -- notif.text = args.text or notif.text
        notif.icon = args.icon or notif.icon
        if notif.icon:wlen() == 1 then
            notif.text_icon.text = notif.icon
        end
        notif.timeout = args.timeout or notif.timeout
    else
        n = naughty.notification(args)
    end
    return n
end

-- suppresses the first time a signal fires for a notif_function so there aren't a bunch of notifications when awesome is first started
notifications.suppress_first = function(signal, notif_function)
    local first_time = true
    local suppressed_function = function(...)
        local args = {...}
        if first_time == true then
            first_time = false
        else
            notif_function(table.unpack(args))
        end
    end
    return suppressed_function
end

local artist_old, song_old
local mpd_sent = false
notifications.mpd_notif = nil
notifications.notify_mpd = function(artist, song, paused, albumart)
    if paused then
        if notifications.mpd_notif then
            notifications.mpd_notif:destroy()
        end
    else
        if song ~= song_old then
            notifications.mpd_notif = notifications.notify(
                {
                    title = "Now playing:",
                    message = "<b>"..song.."</b> by <b>"..artist.."</b>",
                    icon = albumart,
                    timeout = 3,
                    app_name = "mpd"
                },
            notifications.mpd_notif)
        end
    end
    artist_old = artist
    song_old = song
end

notifications.volume_notif = nil
notifications.notify_volume = function(percentage, muted)
    local message, icon
    if muted then
        message = "muted"
    else
        message = tostring(percentage)
    end
    icon = helpers.volume_icon(percentage, muted)
    notifications.volume_notif = notifications.notify(
        {
            title = "Volume",
            message = message,
            icon = icon,
            timeout = 1.5,
            app_name = "volume"
        },
        notifications.volume_notif
    )
end

notifications.brightness_notif = nil
notifications.notify_brightness = function(percentage)
    if paused then
        if notifications.brightness_notif then
            notifications.brightness_notif:destroy()
        end
    else
        local message, icon
        message = tostring(percentage)
        icon = helpers.brightness_icon(percentage)
        notifications.brightness_notif = notifications.notify(
            {
                title = "Brightness",
                message = message,
                icon = icon,
                timeout = 1.5,
                app_name = "brightness"
            },
            notifications.brightness_notif
        )
    end
    artist_old = artist
    song_old = song
end

awesome.connect_signal("meow::mpd", notifications.suppress_first("meow::mpd", notifications.notify_mpd))
awesome.connect_signal("meow::volume", notifications.suppress_first("meow::volume", notifications.notify_volume))
awesome.connect_signal("meow::brightness", notifications.suppress_first("meow::brightness", notifications.notify_brightness))

return notifications