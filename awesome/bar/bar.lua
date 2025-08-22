local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local current_timezone = require("keys/bindings")
local tz = require("timezone")

-- Rose Pine theme colors
local colors = {
    base = "#191724",
    surface = "#1f1d2e",
    overlay = "#26233a",
    muted = "#6e6a86",
    subtle = "#908caa",
    text = "#e0def4",
    love = "#eb6f92",
    gold = "#f6c177",
    rose = "#ebbcba",
    pine = "#31748f",
    foam = "#9ccfd8",
    iris = "#c4a7e7",
    highlight_low = "#21202e",
    highlight_med = "#403d52",
    highlight_high = "#524f67"
}

local M = {}


-- Helper function to create rounded containers with opacity
local function create_container(widget, bg_color, fg_color)
    return wibox.widget {
        {
            {
                widget,
                left = 12,
                right = 12,
                top = 6,
                bottom = 6,
                widget = wibox.container.margin,
            },
            bg = bg_color or colors.surface,
            fg = fg_color or colors.text,
            opacity = 0.95,
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 8)
            end,
            widget = wibox.container.background,
        },
        left = 7,
        right = 7,
        top = 3,
        widget = wibox.container.margin,
    }
end

-- Left section widgets
local function create_left_section(s)
    -- Window title widget
    local window_title = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.focused,
        buttons = gears.table.join(
            awful.button({}, 1, function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    c:emit_signal("request::activate", "tasklist", {raise = true})
                end
            end)
        ),
        style = {
            fg_normal = colors.subtle,
            fg_focus = colors.text,
            bg_focus = colors.highlight_med,
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 6)
            end,
        },
        layout = {
            spacing = 8,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    left = 8,
                    right = 8,
                    widget = wibox.container.margin,
                },
                id = 'background_role',
                widget = wibox.container.background,
            },
            widget = wibox.container.margin,
        },
    }

    -- Current workspace indicator
    local taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.noempty,
        buttons = gears.table.join(
            awful.button({}, 1, function(t) t:view_only() end)
        ),
        style = {
            fg_focus = colors.text,
            bg_focus = colors.iris,
            fg_occupied = colors.subtle,
            bg_occupied = colors.highlight_med,
            fg_empty = colors.muted,
            bg_empty = "transparent",
            shape = function(cr, width, height)
                gears.shape.circle(cr, width, height)
            end,
        },
        layout = {
            spacing = 8,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    id = 'text_role',
                    widget = wibox.widget.textbox,
                },
                margins = 8,
                widget = wibox.container.margin,
            },
            id = 'background_role',
            widget = wibox.container.background,
        },
    }

    local left_section = wibox.widget {
        {
            taglist,
            window_title,
            spacing = 12,
            layout = wibox.layout.fixed.horizontal
        },
        widget = wibox.container.margin,
    }

    return create_container(left_section, colors.surface, colors.text)
end

-- Center section widgets
local function create_center_section()
    -- Date and time widget
    local datetime_widget = wibox.widget.textbox()
    
    local function update_datetime()
        -- Use bash -c to properly handle the TZ environment variable
        v = string.format("TZ=%s date '+%%a %%d %%b %%Y, %%H:%%M:%%S [%%Z]'", tz.get_timezone())
        local cmd = {"bash", "-c", v}
        awful.spawn.easy_async(cmd, function(stdout, stderr, exitreason, exitcode)
            if stdout and stdout:match("%S") and exitcode == 0 then
                local time_str = stdout:gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1")
                datetime_widget:set_markup(
                    '<span foreground="' .. colors.text .. '">' .. time_str .. '</span>'
                )
            else
                -- Fallback: use basic date without timezone
                awful.spawn.easy_async({"date", "+%a %b %d %Y, %I:%M:%S %p"}, function(fallback_stdout)
                    if fallback_stdout and fallback_stdout:match("%S") then
                        local time_str = fallback_stdout:gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1")
                        datetime_widget:set_markup(
                            '<span foreground="' .. colors.text .. '">' .. time_str .. '</span>'
                        )
                    else
                        -- Last resort: use os.date
                        local time_str = os.date("%a %b %d %Y, %I:%M:%S %p")
                        datetime_widget:set_markup(
                            '<span foreground="' .. colors.text .. '">' .. time_str .. '</span>'
                        )
                    end
                end)
            end
        end)
    end
    
    -- Update every second
    gears.timer {
        timeout = 1,
        call_now = true,
        autostart = true,
        callback = update_datetime
    }
    
    -- Create the center widget container first
    local center_widget = wibox.widget {
        {
            datetime_widget,
            layout = wibox.layout.fixed.horizontal
        },
        widget = wibox.container.margin
    }
    
    return create_container(center_widget, colors.surface, colors.text)
end

-- Right section widgets
local function create_right_section()
    -- Volume widgt
     local volume_widget = wibox.widget.textbox()
     local function update_vol()
        awful.spawn.with_line_callback('bash -c "awk -F\"[][]\" \'/dB/ { print $2 }\' <(amixer)"', {
            stdout = function(line)
                volume_widget:set_markup(string.format('<span foreground="%s"> %s</span>', colors.text, line))
            end,
            stderr = function(line)
                naughty.notify({title = "Failed to retrieve current volume level", text = "[Err]: "..line})
            end
        })
     end
 
     gears.timer {
         timeout = 0.5,
         call_now = true,
         autostart = true,
         callback = update_vol
     }

    -- Battery widget
    local battery_widget = wibox.widget.textbox()
    local function update_battery()
        -- Try multiple battery paths
        local path = "/sys/class/power_supply/BAT0"
        
        awful.spawn.easy_async("cat " .. path .. "/capacity 2>/dev/null", function(capacity)
            local cap = tonumber(capacity) or 0
            awful.spawn.easy_async("cat " .. path .. "/status 2>/dev/null", function(status)
                status = status:gsub("\n", "")
                if status == "Charging" or status == "Not charging" then
                    status_icon = "󰂄"
                    color = colors.foam
                elseif status == "Full" or cap >= 98 then
                    status_icon = "󰁹"
                    color = colors.iris
                elseif status == "Discharging" then
                    if cap > 60 then 
                        status_icon = "󰁾"
                        color = colors.iris
                    elseif cap > 30 then
                        status_icon = "󰁼"
                        color = colors.gold
                    else 
                        status_icon = "󰁺"
                        color = colors.rose
                    end
                end
                battery_widget:set_markup(string.format('<span foreground="%s">%s %d%%</span>', color, status_icon, cap))
            end)
        end)
    end
    
    gears.timer {
        timeout = 10,
        call_now = true,
        autostart = true,
        callback = update_battery
    }

    -- Network widget
    local network_widget = wibox.widget.textbox()
    local function update_network()
        -- Multiple fallback methods for network detection
        awful.spawn.easy_async('bash -c "nmcli -t -f DEVICE connection show --active | head -n 1"', function(nic)
            if nic ~= "" then
                -- Check connection type
                awful.spawn.easy_async(string.format('bash -c "ip -4 addr show wlan0 | grep inet | awk \'{print $2}\'"', nic), function(addr)
                    if nic:match("wlan0") then
                        network_widget:set_markup('<span foreground="' .. colors.foam .. '"> '..addr..'</span>')
                    elseif nic:match("eno0") then
                        network_widget:set_markup('<span foreground="' .. colors.foam .. '"> '..addr..'</span>')
                    else
                        network_widget:set_markup('<span foreground="' .. colors.foam .. '"> Connected</span>')
                    end
                end)
            end
        end)
    end
    
    gears.timer {
        timeout = 5,
        call_now = true,
        autostart = true,
        callback = update_network
    }

    -- VPN widget
    local vpn_widget = wibox.widget.textbox()
    local function update_vpn()
        awful.spawn.easy_async('bash -c "nmcli connection show --active | grep sp-vpn"', function(stdout)
            if stdout ~= "" then
                vpn_widget:set_markup('<span foreground="' .. colors.pine .. '">󰖂 </span>')
            else 
                vpn_widget:set_markup("")
            end
        end)
    end
    
    gears.timer {
        timeout = 5,
        call_now = true,
        autostart = true,
        callback = update_vpn
    }

    -- CPU widget
    local cpu_widget = wibox.widget.textbox()
    local function update_cpu()
        awful.spawn.easy_async("grep 'cpu ' /proc/stat", function(stdout)
            local user, nice, system, idle = stdout:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
            if user and nice and system and idle then
                local total = user + nice + system + idle
                local usage = math.floor(((total - idle) / total) * 100)
                local color = usage > 80 and colors.love or (usage > 50 and colors.gold or colors.foam)
                cpu_widget:set_markup(string.format('<span foreground="%s">💻 %d%%</span>', color, usage))
            else
                cpu_widget:set_markup('<span foreground="' .. colors.muted .. '">💻 --</span>')
            end
        end)
    end
    
    gears.timer {
        timeout = 3,
        call_now = true,
        autostart = true,
        callback = update_cpu
    }

    -- Memory widget
    local memory_widget = wibox.widget.textbox()
    local function update_memory()
        awful.spawn.easy_async("cat /proc/meminfo", function(stdout)
            local total = stdout:match("MemTotal:%s*(%d+)") or 0
            local available = stdout:match("MemAvailable:%s*(%d+)") or 0
            if total > 0 and available > 0 then
                local used = total - available
                local usage = math.floor((used / total) * 100)
                local color = usage > 80 and colors.love or (usage > 50 and colors.gold or colors.foam)
                memory_widget:set_markup(string.format('<span foreground="%s">🧠 %d%%</span>', color, usage))
            else
                memory_widget:set_markup('<span foreground="' .. colors.muted .. '">🧠 --</span>')
            end
        end)
    end
    
    gears.timer {
        timeout = 5,
        call_now = true,
        autostart = true,
        callback = update_memory
    }

    local right_section = wibox.widget {
        volume_widget,
        battery_widget,
        network_widget,
        vpn_widget,
        spacing = 16,
        layout = wibox.layout.fixed.horizontal
    }

    return create_container(right_section, colors.surface, colors.text)
end

-- Main wibar creation function
function M.create_wibar(s)
    -- Create the wibar
    s.mywibox = awful.wibar({
        position = "top",
        screen = s,
        height = 36,
        bg = "transparent",
        fg = colors.text,
        type = "dock",
        margins = {
            top = 10,
            left = 0,
            right = 0,
            bottom = 0
        }
    })

    -- Setup the layout with proper flex ratios
    local left_widget = create_left_section(s)
    local center_widget = create_center_section()
    local right_widget = create_right_section()

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            left_widget,
            layout = wibox.layout.fixed.horizontal
        },
        {
            nil,
            center_widget,
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        {
            nil,
            right_widget,
            layout = wibox.layout.align.horizontal
        },
    }
end

return M
