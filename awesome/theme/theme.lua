local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")


beautiful.font = "DejaVuSansM Nerd Font Mono 20"
beautiful.wallpaper = "/home/akingston/.config/awesome/theme/1920x1080.jpg"
beautiful.init("/home/akingston/.config/awesome/theme/default.lua")
function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Create a wibox for each screen and add it
taglist_buttons = gears.table.join(
awful.button({ }, 1, function(t) t:view_only() end),
awful.button({ modkey }, 1, function(t)
    if client.focus then
        client.focus:move_to_tag(t)
    end
end),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, function(t)
    if client.focus then
        client.focus:toggle_tag(t)
    end
end),
awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

tasklist_buttons = gears.table.join(
awful.button({ }, 1, function (c)
    if c == client.focus then
        c.minimized = true
    else
        c:emit_signal(
        "request::activate",
        "tasklist",
        {raise = true}
        )
    end
end),
awful.button({ }, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
end),
awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
end),
awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
end))

-- notifications
-- Define the Rose Pine colors
local rose_pine_colors = {
    base = "#ea9a97",
    surface = "#2a273f",
    mantle = "#49474f",
    overlay1 = "#5a586e",
    overlay2 = "#63606e",
    highlight = "#b48ead"
}

-- Apply the Rose Pine colors to the notification theme
beautiful.notification_font = "DejaVuSansM Nerd Font Mono 10"
beautiful.notification_fg = rose_pine_colors.highlight
beautiful.notification_bg = rose_pine_colors.surface
beautiful.notification_border_width = 0
beautiful.notification_width = 500
beautiful.notification_opacity = 8
beautiful.notification_height = 75
beautiful.notification_margin = 20
beautiful.notification_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 10)
end
-- beautiful.notification_shape = {
--     shape = gears.shape.rounded_rect,
--     shape_radius = 10
-- }

beautiful.border_width = 0
