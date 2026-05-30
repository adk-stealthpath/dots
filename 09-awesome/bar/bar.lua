local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local tz = require("timezone")

-- Everforest theme colors
local colors = {
    base           = "#2b3339", -- background (bg0, medium contrast)
    surface        = "#323c41", -- bg1
    overlay        = "#3a4248", -- bg2
    muted          = "#7a8478", -- gray, muted text
    subtle         = "#9da9a0", -- lighter gray, UI hints
    text           = "#d3c6aa", -- main foreground
    love           = "#e67e80", -- red accent
    gold           = "#dbbc7f", -- yellow/gold accent
    rose           = "#d699b6", -- magenta accent
    pine           = "#a7c080", -- green accent
    foam           = "#7fbbb3", -- blue/teal accent
    iris           = "#83c092", -- aqua/cyan accent
    highlight_low  = "#323c41", -- bg1
    highlight_med  = "#3a4248", -- bg2
    highlight_high = "#4d5960"  -- bg3
}

local M = {}
local gpu_container  -- set during right section creation, used by toggle

-- Helper function to create rounded containers with opacity
local function create_container(widget, bg_color, fg_color)
    return wibox.widget {
        {
            {
                widget,
                left = 12,
                right = 12,
                top = 2,
                bottom = 2,
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
        top = 2,
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
                        ellipsize = "end",
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
            fg_focus = colors.base,
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

    local title_max_width = math.floor(s.geometry.width * 0.35)
    local left_section = wibox.widget {
        {
            taglist,
            {
                window_title,
                strategy = "max",
                width = title_max_width,
                widget = wibox.container.constraint,
            },
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
        local cmd = {"bash", "-c", "date '+%a %d %b, %H:%M:%S [%Z]'"}
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
        datetime_widget,
        layout = wibox.layout.fixed.horizontal
    }
    
    local c = create_container(center_widget, colors.surface, colors.text)
    c.forced_height = 36
    return c
end

-- Right section widgets
local function create_right_section()
    -- Volume widget
    local volume_widget = wibox.widget.textbox()
    local function update_vol()
        awful.spawn.easy_async("pactl get-sink-volume @DEFAULT_SINK@", function(vol_out)
            awful.spawn.easy_async("pactl get-sink-mute @DEFAULT_SINK@", function(mute_out)
                local vol = vol_out:match("(%d+)%%")
                local muted = mute_out:match("Mute: yes") ~= nil
                if vol then
                    local icon = muted and "" or ""
                    local color = muted and colors.muted or colors.text
                    volume_widget:set_markup(string.format(
                        '<span foreground="%s">%s %s%%</span>', color, icon, vol))
                end
            end)
        end)
    end

    gears.timer {
        timeout = 0.5,
        call_now = true,
        autostart = true,
        callback = update_vol
    }

    -- Battery widget
    local battery_widget = wibox.widget.textbox()
    local battery_path = "/sys/class/power_supply/BAT0"

    local function read_battery_file(name)
        local h = io.open(battery_path .. "/" .. name, "r")
        if not h then return nil end
        local line = h:read("*l")
        h:close()
        return line
    end

    local battery_tooltip = awful.tooltip {
        objects = { battery_widget },
        timer_function = function()
            local status = read_battery_file("status") or "Unknown"
            local power = tonumber(read_battery_file("power_now"))
                or tonumber(read_battery_file("current_now"))
            local energy_now = tonumber(read_battery_file("energy_now"))
                or tonumber(read_battery_file("charge_now"))
            local energy_full = tonumber(read_battery_file("energy_full"))
                or tonumber(read_battery_file("charge_full"))

            if status == "Full" then
                return "Battery full"
            end

            if not power or power == 0 or not energy_now or not energy_full then
                return status
            end

            local hours, label
            if status == "Charging" then
                hours = (energy_full - energy_now) / power
                label = "Time to full"
            elseif status == "Discharging" then
                hours = energy_now / power
                label = "Time to empty"
            else
                return status
            end

            local h = math.floor(hours)
            local m = math.floor((hours - h) * 60 + 0.5)
            return string.format("%s: %dh %02dm", label, h, m)
        end,
        timeout = 5,
        margin_leftright = 10,
        margin_topbottom = 6,
        bg = colors.surface,
        fg = colors.text,
        border_color = colors.highlight_high,
        border_width = 1,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 6)
        end,
    }

    local function update_battery()
        awful.spawn.easy_async("cat " .. battery_path .. "/capacity 2>/dev/null", function(capacity)
            local cap = tonumber(capacity) or 0
            awful.spawn.easy_async("cat " .. battery_path .. "/status 2>/dev/null", function(status)
                status = status:gsub("\n", "")
                local status_icon, color
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

    -- CPU widget (delta-based for instantaneous usage)
    local cpu_widget = wibox.widget.textbox()
    local cpu_last = nil
    local function update_cpu()
        awful.spawn.easy_async("grep 'cpu ' /proc/stat", function(stdout)
            local u, n, s, idle, iowait, irq, sirq =
                stdout:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
            if u then
                local total  = u + n + s + idle + iowait + irq + sirq
                local active = total - idle - iowait
                if cpu_last then
                    local dt = total  - cpu_last.total
                    local da = active - cpu_last.active
                    local usage = dt > 0 and math.floor((da / dt) * 100) or 0
                        local color = usage > 80 and colors.love or (usage > 50 and colors.gold or colors.foam)
                    cpu_widget:set_markup(string.format(
                        '<span foreground="%s"> %d%%</span>', color, usage))
                end
                cpu_last = { total = total, active = active }
            else
                cpu_widget:set_markup('<span foreground="' .. colors.muted .. '"> --</span>')
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
        awful.spawn.easy_async("grep -E 'MemTotal|MemAvailable' /proc/meminfo", function(stdout)
            local total     = tonumber(stdout:match("MemTotal:%s*(%d+)"))
            local available = tonumber(stdout:match("MemAvailable:%s*(%d+)"))
            if total and available and total > 0 then
                local usage = math.floor(((total - available) / total) * 100)
                local color = usage > 80 and colors.love or (usage > 50 and colors.rose or colors.pine)
                memory_widget:set_markup(string.format(
                    '<span foreground="%s"> %d%%</span>', color, usage))
            else
                memory_widget:set_markup('<span foreground="' .. colors.muted .. '"> --</span>')
            end
        end)
    end

    gears.timer {
        timeout = 5,
        call_now = true,
        autostart = true,
        callback = update_memory
    }

    -- GPU widget (hidden by default, toggled via keybinding)
    local gpu_widget = wibox.widget.textbox()
    local function update_gpu()
        awful.spawn.easy_async(
            "nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits",
            function(stdout)
                local util, mem_used, mem_total = stdout:match("(%d+),%s*(%d+),%s*(%d+)")
                if util then
                    util     = tonumber(util)
                    mem_used = tonumber(mem_used)
                    local vram = mem_used >= 1024
                        and string.format("%.1fG", mem_used / 1024)
                        or  string.format("%dM",   mem_used)
                    local color = util > 80 and colors.love or (util > 50 and colors.gold or colors.iris)
                    gpu_widget:set_markup(string.format(
                        '<span foreground="%s"> %d%%  %s</span>', color, util, vram))
                else
                    gpu_widget:set_markup('<span foreground="' .. colors.muted .. '"> --</span>')
                end
            end
        )
    end

    gears.timer {
        timeout   = 5,
        call_now  = true,
        autostart = true,
        callback  = update_gpu,
    }

    gpu_container = wibox.widget {
        gpu_widget,
        visible = false,
        widget  = wibox.container.background,
    }

    local right_section = wibox.widget {
        gpu_container,
        cpu_widget,
        memory_widget,
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
        layout = wibox.layout.stack,
        -- Layer 1: left and right sections
        {
            layout = wibox.layout.align.horizontal,
            {
                left_widget,
                layout = wibox.layout.fixed.horizontal
            },
            nil,
            {
                nil,
                right_widget,
                layout = wibox.layout.align.horizontal
            },
        },
        -- Layer 2: clock pinned to the absolute centre of the bar
        {
            center_widget,
            halign = "center",
            valign = "center",
            widget = wibox.container.place,
        },
    }
end

function M.toggle_gpu()
    if gpu_container then
        gpu_container.visible = not gpu_container.visible
    end
end

return M
