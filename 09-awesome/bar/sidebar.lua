-- Niri-style left sidebar for awesome.
-- Replaces the top wibar; mirrors layout/widgets of ~/.config/niri/scripts/sidebar.py.
local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")

local M = {}

-- ── Constants & palette (Everforest, matches sidebar.py CSS) ─────────────────
local SIDEBAR_WIDTH = 260
local NET_IFACE     = "eno0"
local CPU_TEMP_PATH = "/sys/class/hwmon/hwmon3/temp1_input"
local KUBECONFIG    = os.getenv("HOME") .. "/.kube/helmet/merged.yaml"
local DNS_SERVER    = "10.10.0.235"
local IP_SUBNET     = "10.10.0.0/24"
local IP_DYN_START, IP_DYN_END = 31, 130
local IP_DYN_EXCLUDE = { [100] = true, [101] = true, [102] = true }
local SSH_KEY       = os.getenv("HOME") .. "/.ssh/devices__id_rsa"
local SSH_USER      = "sandurz"

local c = {
    bg_glass = "#2d353b8c",  -- ~55% alpha glass
    bg_panel = "#323c41",
    surface  = "#475258",
    sep      = "#475258",
    muted    = "#859289",
    text     = "#d3c6aa",
    accent   = "#a7c080",   -- pine
    iris     = "#83c092",
    rose     = "#d699b6",
    gold     = "#dbbc7f",
    love     = "#e67e80",
    foam     = "#7fbbb3",
}

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function sep()
    return wibox.widget {
        {
            forced_height = 1,
            bg = c.sep,
            opacity = 0.5,
            widget = wibox.container.background,
        },
        left = 16, right = 16, top = 4, bottom = 4,
        widget = wibox.container.margin,
    }
end

local function rounded(radius)
    return function(cr, w, h) gears.shape.rounded_rect(cr, w, h, radius or 8) end
end

-- Async helper: run a shell command and pass stdout to callback.
local function run(cmd, cb)
    awful.spawn.easy_async_with_shell(cmd, function(stdout) cb(stdout or "") end)
end

-- ── 1. Workspaces (vertical column of tag buttons) ───────────────────────────

local function workspaces_widget(s)
    local taglist = awful.widget.taglist {
        screen = s,
        filter = function(t) return t.index <= 4 end,
        buttons = gears.table.join(
            awful.button({}, 1, function(t) t:view_only() end)
        ),
        style = {
            shape       = rounded(8),
            bg_focus    = c.bg_panel,
            fg_focus    = c.accent,
            fg_occupied = c.text,
            fg_empty    = c.muted,
        },
        layout = { layout = wibox.layout.flex.horizontal, spacing = 4 },
        widget_template = {
            {
                {
                    {
                        id = "text_role",
                        align = "center",
                        font = "JetBrainsMono Nerd Font Bold 13",
                        widget = wibox.widget.textbox,
                    },
                    margins = 8,
                    widget = wibox.container.margin,
                },
                id = "background_role",
                widget = wibox.container.background,
            },
            widget = wibox.container.margin,
        },
    }
    return wibox.widget {
        taglist,
        left = 10, right = 10, top = 4, bottom = 8,
        widget = wibox.container.margin,
    }
end

-- ── 2. Clock + date ──────────────────────────────────────────────────────────

local function clock_widget()
    local time_lbl = wibox.widget.textbox()
    time_lbl.font = "JetBrainsMono Nerd Font Bold 31"
    time_lbl.align = "left"

    local date_lbl = wibox.widget.textbox()
    date_lbl.font = "JetBrainsMono Nerd Font 9"

    local function tick()
        local t = os.date("*t")
        local hhmm = string.format("%02d:%02d", t.hour, t.min)
        local tz = os.date("%Z")
        time_lbl:set_markup(
            string.format(
                '<span foreground="%s" weight="700">%s</span>'..
                '<span foreground="%s" size="60%%" weight="600">  %s</span>',
                c.accent, hhmm, c.iris, tz))
        date_lbl:set_markup(
            string.format('<span foreground="%s">%s</span>',
                c.iris, os.date("%A, %d %B %Y")))
    end
    tick()
    gears.timer { timeout = 5, autostart = true, callback = tick }

    return wibox.widget {
        {
            time_lbl,
            date_lbl,
            spacing = 2,
            layout = wibox.layout.fixed.vertical,
        },
        left = 16, right = 16, top = 0, bottom = 8,
        widget = wibox.container.margin,
    }
end

-- ── 3. Calendar (inline static month grid) ───────────────────────────────────

local function calendar_widget()
    local hdr_lbl = wibox.widget.textbox()
    hdr_lbl.font = "JetBrainsMono Nerd Font Bold 11"
    hdr_lbl.align = "center"

    local grid = wibox.layout.grid()
    grid.forced_num_cols = 7
    grid.expand           = true
    grid.homogeneous      = true
    grid.spacing          = 0

    local function cell(markup)
        return wibox.widget {
            markup = markup,
            align  = "center",
            font   = "JetBrainsMono Nerd Font 9",
            widget = wibox.widget.textbox,
        }
    end

    local function render()
        local now = os.date("*t")
        local first = os.time{ year = now.year, month = now.month, day = 1, hour = 12 }
        local first_dow = tonumber(os.date("%w", first))
        local mon_offset = (first_dow + 6) % 7
        local days_in_month = ({31,28,31,30,31,30,31,31,30,31,30,31})[now.month]
        if now.month == 2 and ((now.year % 4 == 0 and now.year % 100 ~= 0) or now.year % 400 == 0) then
            days_in_month = 29
        end

        hdr_lbl:set_markup(string.format(
            '<span foreground="%s" weight="700">%s %d</span>',
            c.rose, os.date("%B"), now.year))

        grid:reset()
        for _, d in ipairs({"Mo","Tu","We","Th","Fr","Sa","Su"}) do
            grid:add(cell(string.format('<span foreground="%s">%s</span>', c.muted, d)))
        end
        for _ = 1, mon_offset do grid:add(cell("")) end
        for d = 1, days_in_month do
            if d == now.day then
                grid:add(cell(string.format(
                    '<span foreground="%s" weight="700">%d</span>', c.accent, d)))
            else
                grid:add(cell(string.format(
                    '<span foreground="%s">%d</span>', c.text, d)))
            end
        end
    end
    render()
    gears.timer { timeout = 60, autostart = true, callback = render }

    return wibox.widget {
        {
            hdr_lbl,
            grid,
            spacing = 4,
            layout  = wibox.layout.fixed.vertical,
        },
        left = 12, right = 12, top = 4, bottom = 8,
        widget = wibox.container.margin,
    }
end

-- ── 4. Kube contexts ─────────────────────────────────────────────────────────

local function section_header(text)
    local lbl = wibox.widget.textbox()
    lbl.font = "JetBrainsMono Nerd Font Bold 8"
    lbl:set_markup(string.format('<span foreground="%s">%s</span>', c.muted, text))
    return lbl
end

local function kube_widget()
    local container = wibox.layout.fixed.vertical()
    container.spacing = 2

    local hdr_box = wibox.widget {
        section_header("KUBE CONTEXTS"),
        nil,
        {
            wibox.widget {
                markup = string.format('<span foreground="%s">⎈ helmet</span>', c.iris),
                widget = wibox.widget.textbox,
            },
            buttons = gears.table.join(
                awful.button({}, 1, function()
                    awful.spawn.with_shell(
                        "alacritty --class helmet-float -e bash -c 'helmet; echo; echo --- done; read'")
                end)),
            widget = wibox.container.background,
        },
        layout = wibox.layout.align.horizontal,
    }

    local list_box = wibox.layout.fixed.vertical()
    list_box.spacing = 2

    local function refresh()
        run("KUBECONFIG=" .. KUBECONFIG .. " kubectl config get-contexts -o name", function(stdout)
            run("KUBECONFIG=" .. KUBECONFIG .. " kubectl config current-context", function(curOut)
                local current = (curOut:gsub("%s+$", ""))
                list_box:reset()
                for ctx in stdout:gmatch("[^\r\n]+") do
                    ctx = ctx:gsub("%s+$", "")
                    if #ctx > 0 then
                        local active = (ctx == current)
                        local color = active and c.accent or c.muted
                        local row = wibox.widget {
                            {
                                {
                                    markup = string.format(
                                        '<span foreground="%s">%s</span>', color, ctx),
                                    font      = "JetBrainsMono Nerd Font 9",
                                    ellipsize = "end",
                                    widget = wibox.widget.textbox,
                                },
                                left = 8, right = 8, top = 4, bottom = 4,
                                widget = wibox.container.margin,
                            },
                            bg = active and c.bg_panel or "transparent",
                            shape = rounded(6),
                            buttons = gears.table.join(
                                awful.button({}, 1, function()
                                    awful.spawn.with_shell(
                                        "KUBECONFIG=" .. KUBECONFIG ..
                                        " kubectl config use-context " .. ctx)
                                    gears.timer.start_new(0.4, function() refresh(); return false end)
                                end)),
                            widget = wibox.container.background,
                        }
                        list_box:add(row)
                    end
                end
            end)
        end)
    end
    refresh()
    gears.timer { timeout = 5, autostart = true, callback = refresh }

    container:add(hdr_box)
    container:add(list_box)
    return wibox.widget {
        container,
        left = 14, right = 14, top = 6, bottom = 6,
        widget = wibox.container.margin,
    }
end

-- ── 5. IP scan ───────────────────────────────────────────────────────────────

local function ip_scan_widget()
    local container = wibox.layout.fixed.vertical()
    container.spacing = 2
    container:add(section_header(IP_SUBNET))

    local list_box = wibox.layout.fixed.vertical()
    list_box.spacing = 2
    container:add(list_box)

    local function refresh()
        local cmd = string.format(
            "arp-scan -I %s %s 2>/dev/null | awk -F'\\t' '/^10\\.10\\.0\\./{print $1\" \"$3}'",
            NET_IFACE, IP_SUBNET)
        run(cmd, function(stdout)
            local entries = {}
            for line in stdout:gmatch("[^\r\n]+") do
                local ip, vendor = line:match("^(%S+)%s*(.*)$")
                if ip then
                    table.insert(entries, { ip = ip, vendor = (vendor or ""):sub(1, 30) })
                end
            end
            -- PTR resolve in parallel via background spawns; simplest: build a
            -- combined dig command for all IPs.
            if #entries == 0 then
                list_box:reset()
                return
            end
            local ips_cli = ""
            for _, e in ipairs(entries) do
                ips_cli = ips_cli .. " -x " .. e.ip
            end
            local dig_cmd = string.format(
                "dig +noall +answer +time=1 +tries=1 @%s %s 2>/dev/null", DNS_SERVER, ips_cli)
            run(dig_cmd, function(digOut)
                local ptrs = {}
                for line in digOut:gmatch("[^\r\n]+") do
                    local rev, name = line:match("^(%S+)%s+%S+%s+IN%s+PTR%s+(%S+)")
                    if rev and name then
                        local octets = {}
                        for o in rev:gmatch("(%d+)") do
                            table.insert(octets, o)
                        end
                        if #octets >= 4 then
                            local ip = string.format("%s.%s.%s.%s",
                                octets[4], octets[3], octets[2], octets[1])
                            ptrs[ip] = (name:gsub("%.$", ""))
                        end
                    end
                end

                local function render()
                    list_box:reset()
                    table.sort(entries, function(a, b)
                        local na = tonumber(a.ip:match("(%d+)$")) or 0
                        local nb = tonumber(b.ip:match("(%d+)$")) or 0
                        return na < nb
                    end)
                    for _, e in ipairs(entries) do
                        local octet = e.ip:match("(%d+)$")
                        local name = ptrs[e.ip] or e.vendor or ""
                        local row = wibox.widget {
                            {
                                markup    = string.format(
                                    '<span foreground="%s">%s</span>', c.text, name),
                                font      = "JetBrainsMono Nerd Font 9",
                                ellipsize = "end",
                                widget    = wibox.widget.textbox,
                            },
                            nil,
                            {
                                markup = string.format(
                                    '<span foreground="%s">.%s</span>', c.muted, octet or "?"),
                                font   = "JetBrainsMono Nerd Font 9",
                                widget = wibox.widget.textbox,
                            },
                            layout = wibox.layout.align.horizontal,
                        }
                        list_box:add(row)
                    end
                end

                local function is_dynamic(ip)
                    local n = tonumber(ip:match("(%d+)$")) or -1
                    return n >= IP_DYN_START and n <= IP_DYN_END
                        and not IP_DYN_EXCLUDE[n]
                end

                local pending = 0
                local function ssh_lookup(ip)
                    pending = pending + 1
                    local cmd = string.format(
                        "ssh -i %s "
                        .. "-o StrictHostKeyChecking=no "
                        .. "-o UserKnownHostsFile=/dev/null "
                        .. "-o ConnectTimeout=3 "
                        .. "-o BatchMode=yes "
                        .. "%s@%s \"grep '^127.0.1.1' /etc/hosts\" 2>/dev/null",
                        SSH_KEY, SSH_USER, ip)
                    run(cmd, function(out)
                        for line in out:gmatch("[^\r\n]+") do
                            local _, hostname = line:match("^(%S+)%s+(%S+)")
                            if hostname then
                                local last_end
                                local pos = 1
                                while true do
                                    local s, e = hostname:find("%-%d+%-", pos)
                                    if not s then break end
                                    last_end = e
                                    pos = e + 1
                                end
                                if last_end then
                                    local suffix = hostname:sub(last_end + 1)
                                    if suffix and #suffix > 0 then
                                        ptrs[ip] = SSH_USER .. "." .. suffix
                                        break
                                    end
                                end
                            end
                        end
                        pending = pending - 1
                        if pending == 0 then render() end
                    end)
                end

                for _, e in ipairs(entries) do
                    if not ptrs[e.ip] and is_dynamic(e.ip) then
                        ssh_lookup(e.ip)
                    end
                end
                if pending == 0 then render() end
            end)
        end)
    end
    -- arp-scan is slow; first run delayed to let session settle.
    gears.timer.start_new(2, function() refresh(); return false end)
    gears.timer { timeout = 30, autostart = true, callback = refresh }

    return wibox.widget {
        container,
        left = 14, right = 14, top = 6, bottom = 6,
        widget = wibox.container.margin,
    }
end

-- ── 6. Stats ─────────────────────────────────────────────────────────────────

local function stat_row(icon, label, color, val_init)
    local icon_lbl = wibox.widget.textbox()
    icon_lbl.font = "JetBrainsMono Nerd Font 9"
    icon_lbl:set_markup(string.format('<span foreground="%s">%s</span>', color, icon))
    icon_lbl.forced_width = 24

    local name_lbl = wibox.widget.textbox()
    name_lbl.font = "JetBrainsMono Nerd Font 9"
    name_lbl:set_markup(string.format('<span foreground="%s">%s</span>', c.muted, label))

    local val_lbl = wibox.widget.textbox()
    val_lbl.font = "JetBrainsMono Nerd Font 9"
    val_lbl:set_markup(string.format('<span foreground="%s">%s</span>', c.text, val_init or "…"))
    val_lbl.align = "right"

    local icon_wrap = wibox.widget {
        icon_lbl,
        left = 0, right = 6, top = 0, bottom = 0,
        widget = wibox.container.margin,
    }

    local left = wibox.widget {
        icon_wrap,
        name_lbl,
        spacing = 6,
        layout  = wibox.layout.fixed.horizontal,
    }

    local row = wibox.widget {
        {
            left,
            nil,
            val_lbl,
            layout  = wibox.layout.align.horizontal,
        },
        left = 4, right = 4, top = 5, bottom = 5,
        widget = wibox.container.margin,
    }

    return row, val_lbl, icon_lbl
end

local function stats_widget()
    local container = wibox.layout.fixed.vertical()

    local cpu_row, cpu_val, cpu_icon = stat_row("󰻠", "CPU",  c.gold, "?")
    local mem_row, mem_val           = stat_row("󰍛", "MEM",  c.love, "?")
    local gpu_row, gpu_val, gpu_icon = stat_row("󰍹", "GPU",  c.rose, "?")
    local vol_row, vol_val           = stat_row("󰕾", "VOL",  c.iris, "?")
    local net_row, net_val           = stat_row("󰜮", "NET",  c.gold, "?")
    local lat_row, lat_val           = stat_row("󰓅", "PING", c.muted, "?")
    container:add(cpu_row); container:add(mem_row); container:add(gpu_row)
    container:add(vol_row); container:add(net_row); container:add(lat_row)

    -- CPU + cpu temp colour
    local cpu_last
    local function tick_cpu()
        run("cat /proc/stat | head -1", function(out)
            local u, n, sy, idle = out:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
            if not u then return end
            u, n, sy, idle = tonumber(u), tonumber(n), tonumber(sy), tonumber(idle)
            local total, active = u + n + sy + idle, u + n + sy
            local pct = "?"
            if cpu_last then
                local dt, da = total - cpu_last.total, active - cpu_last.active
                pct = (dt > 0) and tostring(math.floor(da / dt * 100)) or "0"
            end
            cpu_last = { total = total, active = active }
            run("cat " .. CPU_TEMP_PATH .. " 2>/dev/null", function(temp_raw)
                local temp_c = tonumber((temp_raw:gsub("%s+", "")))
                local temp_lbl, color = "?", c.muted
                if temp_c then
                    local deg = math.floor(temp_c / 1000)
                    temp_lbl = deg .. "°C"
                    color = (deg < 60) and c.iris or (deg < 75) and c.gold or c.love
                end
                cpu_val:set_markup(string.format('<span foreground="%s">%s%%  %s</span>',
                    c.text, pct, temp_lbl))
                cpu_icon:set_markup(string.format('<span foreground="%s">󰻠</span>', color))
            end)
        end)
    end

    -- Memory
    local function tick_mem()
        run("grep -E 'MemTotal|MemAvailable' /proc/meminfo", function(out)
            local total = tonumber(out:match("MemTotal:%s*(%d+)"))
            local avail = tonumber(out:match("MemAvailable:%s*(%d+)"))
            if total and avail and total > 0 then
                local pct = math.floor((total - avail) / total * 100)
                mem_val:set_markup(string.format('<span foreground="%s">%d%%</span>', c.text, pct))
            end
        end)
    end

    -- GPU (nvidia-smi)
    local function tick_gpu()
        run("nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null",
            function(out)
                local util_s, temp_s = out:match("(%d+),%s*(%d+)")
                if not util_s then return end
                local util_n, temp_n = tonumber(util_s), tonumber(temp_s)
                local color = (temp_n < 60) and c.iris or (temp_n < 75) and c.gold or c.love
                gpu_val:set_markup(string.format('<span foreground="%s">%d%%  %d°C</span>',
                    c.text, util_n, temp_n))
                gpu_icon:set_markup(string.format('<span foreground="%s">󰍹</span>', color))
            end)
    end

    -- Volume (wpctl, niri-style)
    local function tick_vol()
        run("wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null", function(out)
            local v = out:match("Volume:%s*([%d%.]+)")
            local muted = out:match("MUTED")
            if muted then
                vol_val:set_markup(string.format('<span foreground="%s">muted</span>', c.muted))
            elseif v then
                vol_val:set_markup(string.format(
                    '<span foreground="%s">%d%%</span>', c.text, math.floor(tonumber(v) * 100)))
            end
        end)
    end

    -- Network (IP + rate)
    local net_last
    local function tick_net()
        run(string.format(
            "ip -4 addr show %s 2>/dev/null | awk '/inet /{print $2}'", NET_IFACE),
            function(ipOut)
                local ip = (ipOut:gsub("/.*", ""):gsub("%s+", ""))
                run("cat /proc/net/dev", function(devOut)
                    for line in devOut:gmatch("[^\r\n]+") do
                        if line:find(NET_IFACE) then
                            local fields = {}
                            for f in line:gmatch("%S+") do table.insert(fields, f) end
                            local rx = tonumber(fields[2]) or 0
                            local tx = tonumber(fields[10]) or 0
                            local now = os.time()
                            local rate = ""
                            if net_last then
                                local dt = now - net_last.t
                                if dt > 0 then
                                    local drx = math.floor((rx - net_last.rx) / dt / 1024)
                                    local dtx = math.floor((tx - net_last.tx) / dt / 1024)
                                    rate = string.format("↓%dK ↑%dK", drx, dtx)
                                end
                            end
                            net_last = { t = now, rx = rx, tx = tx }
                            net_val:set_markup(string.format(
                                '<span foreground="%s">%s</span>'..
                                '<span foreground="%s" size="80%%">  %s</span>',
                                c.text, ip ~= "" and ip or "?", c.muted, rate))
                            return
                        end
                    end
                end)
            end)
    end

    -- Ping (1.1.1.1)
    local function tick_lat()
        run("ping -c 1 -W 1 1.1.1.1 2>/dev/null", function(out)
            local ms = out:match("time=([%d%.]+)")
            local s = ms and string.format("%.0fms", tonumber(ms)) or "n/a"
            lat_val:set_markup(string.format('<span foreground="%s">%s</span>', c.text, s))
        end)
    end

    tick_cpu(); tick_mem(); tick_gpu(); tick_vol(); tick_net(); tick_lat()
    gears.timer { timeout = 2,  autostart = true, callback = tick_cpu }
    gears.timer { timeout = 5,  autostart = true, callback = tick_mem }
    gears.timer { timeout = 5,  autostart = true, callback = tick_gpu }
    gears.timer { timeout = 1,  autostart = true, callback = tick_vol }
    gears.timer { timeout = 2,  autostart = true, callback = tick_net }
    gears.timer { timeout = 10, autostart = true, callback = tick_lat }

    return wibox.widget {
        container,
        left = 14, right = 14, top = 4, bottom = 4,
        widget = wibox.container.margin,
    }
end

-- ── 7. DND toggle (mako) ─────────────────────────────────────────────────────

local function dnd_widget()
    local lbl = wibox.widget.textbox()
    lbl.font  = "JetBrainsMono Nerd Font 9"
    lbl.align = "center"

    local function tick()
        run("makoctl mode 2>/dev/null", function(out)
            local active = out:find("do%-not%-disturb") ~= nil
            local color = active and c.accent or c.muted
            local txt = active and "󰂞  Do Not Disturb" or "󰂟  Notifications on"
            lbl:set_markup(string.format(
                '<span foreground="%s">%s</span>', color, txt))
        end)
    end
    tick()
    gears.timer { timeout = 3, autostart = true, callback = tick }

    return wibox.widget {
        {
            {
                lbl,
                left = 0, right = 0, top = 7, bottom = 7,
                widget = wibox.container.margin,
            },
            bg = c.bg_panel,
            shape = rounded(8),
            buttons = gears.table.join(
                awful.button({}, 1, function()
                    awful.spawn.with_shell("makoctl mode -t do-not-disturb")
                    gears.timer.start_new(0.3, function() tick(); return false end)
                end)),
            widget = wibox.container.background,
        },
        left = 14, right = 14, top = 4, bottom = 4,
        widget = wibox.container.margin,
    }
end

-- ── Confirm modal ────────────────────────────────────────────────────────────

local function confirm_modal(title, body, action)
    local s = awful.screen.focused()
    local m = wibox {
        screen = s, ontop = true, visible = true, type = "dialog",
        width = 280, height = 130,
        bg = c.bg_panel, fg = c.text,
        shape = rounded(12),
    }
    awful.placement.centered(m, { parent = s })

    local title_lbl = wibox.widget.textbox()
    title_lbl:set_markup(string.format(
        '<span foreground="%s" weight="700" size="13200">%s</span>', c.text, title))
    local body_lbl = wibox.widget.textbox()
    body_lbl:set_markup(string.format(
        '<span foreground="%s" size="10800">%s</span>', c.muted, body))

    local ok_btn = wibox.widget {
        {
            { markup = string.format('<span foreground="%s" weight="600">Confirm</span>', c.accent),
              widget = wibox.widget.textbox, align = "center" },
            left = 0, right = 0, top = 8, bottom = 8,
            widget = wibox.container.margin,
        },
        bg = c.surface,
        shape = rounded(8),
        buttons = gears.table.join(
            awful.button({}, 1, function() m.visible = false; action() end)),
        widget = wibox.container.background,
    }
    local cancel_btn = wibox.widget {
        {
            { markup = string.format('<span foreground="%s">Cancel</span>', c.muted),
              widget = wibox.widget.textbox, align = "center" },
            left = 0, right = 0, top = 8, bottom = 8,
            widget = wibox.container.margin,
        },
        bg = c.surface,
        shape = rounded(8),
        buttons = gears.table.join(
            awful.button({}, 1, function() m.visible = false end)),
        widget = wibox.container.background,
    }

    m:setup {
        {
            title_lbl,
            body_lbl,
            {
                cancel_btn,
                ok_btn,
                spacing = 8,
                layout = wibox.layout.flex.horizontal,
            },
            spacing = 6,
            layout = wibox.layout.fixed.vertical,
        },
        margins = 16,
        widget = wibox.container.margin,
    }
end

-- ── 8. Power grid + VPN/Tailscale toggles ────────────────────────────────────

local function ico_btn(icon, color, callback, tooltip_text)
    local lbl = wibox.widget.textbox()
    lbl.align = "center"
    lbl:set_markup(string.format('<span foreground="%s" size="15600">%s</span>',
        color or c.muted, icon))
    local bg_bg = c.bg_panel
    local btn = wibox.widget {
        {
            lbl,
            left = 6, right = 6, top = 10, bottom = 10,
            widget = wibox.container.margin,
        },
        bg = bg_bg,
        shape = rounded(8),
        buttons = gears.table.join(awful.button({}, 1, callback)),
        widget = wibox.container.background,
    }
    if tooltip_text then
        awful.tooltip { objects = { btn }, text = tooltip_text }
    end
    return btn, lbl
end

local function power_grid_widget()
    local lock_btn   = ico_btn("󰌾", c.muted, function()
        awful.spawn("swaylock")
    end, "Lock")
    local restart_btn = ico_btn("󰑓", c.muted, function()
        confirm_modal("Restart?", "The system will reboot.",
            function() awful.spawn("systemctl reboot") end)
    end, "Restart")
    local shut_btn  = ico_btn("󰐥", c.muted, function()
        confirm_modal("Shut down?", "The system will power off.",
            function() awful.spawn("systemctl poweroff") end)
    end, "Shutdown")
    local logout_btn = ico_btn("󰗽", c.muted, function()
        confirm_modal("Log out?", "Your awesome session will end.",
            function() awesome.quit() end)
    end, "Log out")

    -- VPN button (nmcli sp-vpn)
    local vpn_btn, vpn_lbl = ico_btn("󰦝", c.muted, function() end, "VPN")
    local function tick_vpn()
        run("nmcli -t -f NAME,STATE con show --active", function(out)
            local active = out:find("sp%-vpn") ~= nil
            local color = active and c.iris or c.muted
            vpn_lbl:set_markup(string.format(
                '<span foreground="%s" size="15600">󰦝</span>', color))
            vpn_btn.buttons = gears.table.join(awful.button({}, 1, function()
                local cmd = active and "nmcli con down sp-vpn" or "nmcli con up sp-vpn"
                awful.spawn.with_shell(cmd)
                gears.timer.start_new(1.5, function() tick_vpn(); return false end)
            end))
        end)
    end
    tick_vpn()
    gears.timer { timeout = 5, autostart = true, callback = tick_vpn }

    -- Tailscale button
    local ts_btn, ts_lbl = ico_btn("󰖂", c.muted, function() end, "Tailscale")
    local function tick_ts()
        run("tailscale status --json 2>/dev/null", function(out)
            local active = out:find('"BackendState"%s*:%s*"Running"') ~= nil
            local color = active and c.iris or c.muted
            ts_lbl:set_markup(string.format(
                '<span foreground="%s" size="15600">󰖂</span>', color))
            ts_btn.buttons = gears.table.join(awful.button({}, 1, function()
                local cmd = active and "tailscale down" or "tailscale up"
                awful.spawn.with_shell(cmd)
                gears.timer.start_new(1.5, function() tick_ts(); return false end)
            end))
        end)
    end
    tick_ts()
    gears.timer { timeout = 5, autostart = true, callback = tick_ts }

    local row1 = wibox.widget {
        lock_btn, restart_btn, shut_btn,
        spacing = 6,
        layout = wibox.layout.flex.horizontal,
    }
    local row2 = wibox.widget {
        logout_btn, vpn_btn, ts_btn,
        spacing = 6,
        layout = wibox.layout.flex.horizontal,
    }
    return wibox.widget {
        {
            row1, row2,
            spacing = 6,
            layout = wibox.layout.fixed.vertical,
        },
        left = 14, right = 14, top = 4, bottom = 8,
        widget = wibox.container.margin,
    }
end

-- ── Public: build sidebar for screen ─────────────────────────────────────────

function M.create_sidebar(s)
    s.mywibox = awful.wibar({
        position = "left",
        screen   = s,
        width    = SIDEBAR_WIDTH,
        bg       = c.bg_glass,
        fg       = c.text,
        type     = "dock",
    })

    local top_section = wibox.widget {
        workspaces_widget(s),
        sep(),
        clock_widget(),
        calendar_widget(),
        sep(),
        kube_widget(),
        sep(),
        ip_scan_widget(),
        spacing = 0,
        layout  = wibox.layout.fixed.vertical,
    }

    local bottom_section = wibox.widget {
        sep(),
        stats_widget(),
        sep(),
        dnd_widget(),
        sep(),
        power_grid_widget(),
        spacing = 0,
        layout  = wibox.layout.fixed.vertical,
    }

    s.mywibox:setup {
        {
            top_section,
            { bg = c.bg_glass, widget = wibox.container.background },
            bottom_section,
            layout = wibox.layout.align.vertical,
        },
        top = 12, bottom = 8,
        widget = wibox.container.margin,
    }
end

M.SIDEBAR_WIDTH = SIDEBAR_WIDTH
return M
