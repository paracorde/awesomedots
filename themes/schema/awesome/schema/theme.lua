local gears = require("gears")
local theme_name = "schema"

local theme = {}

-- theme values
theme.useless_gap = dpi(15)
theme.screen_margin = dpi(30)

-- ui values
theme.ui_radius = x.radius
theme.ui_fg = x.foreground
theme.ui_bg = x.background
theme.ui_cover_bg = x.background
theme.ui_light_bg = x.color7
theme.ui_border_width = dpi(2)
theme.ui_border_color = x.foreground

-- fonts
theme.font = "Sen"
theme.font_large = theme.font.." 16"
theme.font_small = theme.font.." 9"
theme.font = theme.font.." 12"
theme.font_mono = "DM Mono 15"
theme.icon = "maplenerdmono"
theme.icon_large = theme.icon.." 20"
theme.icon_extra_large = theme.icon.." 30"
theme.icon_small = theme.icon.." 13"
theme.icon = theme.icon.." 16"

-- border values
theme.border_width = dpi(2)
theme.border_color = x.foreground
-- theme.border_color_normal = x.background
theme.border_color_normal = x.foreground
theme.border_color_active = x.foreground
theme.border_radius = theme.ui_radius

-- decoration settings
theme.titlebars_enabled = true
theme.titlebar_title_enabled = false
theme.titlebar_font = theme.font
theme.titlebar_size = dpi(30)
theme.titlebar_title_align = "center"
theme.titlebar_position = "top"
theme.titlebar_fg = x.foreground
-- theme.titlebar_fg_normal = x.foreground
-- theme.titlebar_fg_focus = x.foreground
theme.titlebar_bg = x.background
-- theme.titlebar_bg_normal = x.color15
-- theme.titlebar_bg_focus = x.color7

-- notification settings
theme.notification_font = theme.font
theme.notification_bg = x.background
theme.notification_title_bg = x.background
-- theme.notification_title_bg = x.color15
theme.notification_margin = dpi(15)
theme.notification_spacing = dpi(15)

-- bar settings
theme.bar_position = "top"
theme.bar_height = dpi(40)
theme.bar_bg = theme.ui_bg
theme.bar_prefix_fg = x.foreground

-- taglist settings
theme.taglist_text_empty    = {"獆","獇","獈","獃","獄","獅","7","8","9","0"}
theme.taglist_text_occupied = {"獆","獇","獈","獃","獄","獅","7","8","9","0"}
theme.taglist_text_focused  = {"獆","獇","獈","獃","獄","獅","7","8","9","0"}
-- theme.taglist_text_focused  = {"羛","羜","羝","羘","羙","羚","7","8","9","0"}
theme.taglist_text_urgent   = {"獆","獇","獈","獃","獄","獅","+","+","+","+"}

theme.taglist_text_color_empty = {x.color7, x.color7, x.color7, x.color7, x.color7, x.color7, x.color7, x.color7, x.color7, x.color7}
theme.taglist_text_color_focused  = {x.foreground, x.foreground, x.foreground, x.foreground, x.foreground, x.foreground, x.foreground, x.foreground, x.foreground, x.foreground}
theme.taglist_text_color_occupied = {x.color8, x.color8, x.color8, x.color8, x.color8, x.color8, x.color8, x.color8, x.color8, x.color8}
theme.taglist_text_color_urgent = {x.color2, x.color2, x.color2, x.color2, x.color2, x.color2, x.color2, x.color2, x.color2, x.color2}

-- values for various bars
-- battery
theme.battery_bar_active_color = x.color5
theme.battery_bar_active_background_color = x.color7
theme.battery_bar_charging_color = x.color6
theme.battery_bar_charging_background_color = x.color7

-- volume
theme.volume_bar_active_color = x.color4
theme.volume_bar_active_background_color = x.color7
theme.volume_bar_muted_color = x.color8
theme.volume_bar_muted_background_color = x.color7

-- brightness
theme.brightness_bar_active_color = x.color3
theme.brightness_bar_background_color = x.color7

-- cpu
theme.cpu_bar_active_color = x.color1
theme.cpu_bar_background_color = x.color7

-- ram
theme.ram_bar_active_color = x.color4
theme.ram_bar_background_color = x.color7

-- temperature
theme.temperature_bar_active_color = x.color3
theme.temperature_bar_background_color = x.color7

return theme