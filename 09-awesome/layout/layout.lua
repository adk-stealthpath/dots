local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

-- Define your custom layout
local custom_layout = {}
custom_layout.name = "custom_split"

function custom_layout.arrange(p)
    local area = p.workarea
    local clients = p.clients
    local n = #clients
    
    if n == 0 then return end
    
    if n == 1 then
        -- Single window: middle half of screen
        local width = area.width * 0.5
        local x = area.x + (area.width * 0.25)  -- Center it
        
        local g = {
            x = x,
            y = area.y,
            width = width,
            height = area.height
        }
        p.geometries[clients[1]] = g
        
    elseif n == 2 then
        -- Two windows: 2/3 and 1/3 split
        local g1 = {
            x = area.x,
            y = area.y,
            width = area.width * (2/3),
            height = area.height
        }
        local g2 = {
            x = area.x + (area.width * (2/3)),
            y = area.y,
            width = area.width * (1/3),
            height = area.height
        }
        p.geometries[clients[1]] = g1
        p.geometries[clients[2]] = g2
        
    elseif n == 3 then
        -- Three windows: 1/4, 1/2, 1/4 split
        local g1 = {
            x = area.x,
            y = area.y,
            width = area.width * 0.25,
            height = area.height
        }
        local g2 = {
            x = area.x + (area.width * 0.25),
            y = area.y,
            width = area.width * 0.5,
            height = area.height
        }
        local g3 = {
            x = area.x + (area.width * 0.75),
            y = area.y,
            width = area.width * 0.25,
            height = area.height
        }
        p.geometries[clients[1]] = g1
        p.geometries[clients[2]] = g2
        p.geometries[clients[3]] = g3
        
    else
        -- For 4+ windows, you can either tile them however you want
        -- or fall back to awful.layout.suit.tile
        -- Here's a simple equal split as fallback:
        local width = area.width / n
        for i, c in ipairs(clients) do
            local g = {
                x = area.x + ((i-1) * width),
                y = area.y,
                width = width,
                height = area.height
            }
            p.geometries[c] = g
        end
    end
end

-- Add the layout to awful's layout list
awful.layout.suit.custom_split = custom_layout

-- Add the custom layout to your layouts table
-- Find this section in your rc.lua and add custom_layout:

-- Example of how to add it to your layouts:
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    custom_layout,  -- Add your custom layout here
}

-- Keybinding to set your custom layout
-- Add this to your globalkeys:
awful.key({ modkey, "Shift" }, "c", function()
    awful.layout.set(custom_layout, mouse.screen.selected_tag)
end, {description = "set custom layout", group = "layout"})

-- Auto-apply custom layout to 5120x1440 monitor
-- Add this after your screen setup but before the end of rc.lua:

-- Function to set layout for ultrawide monitor
local function setup_ultrawide_layout()
    for s in screen do
        local geo = s.geometry
        -- Check if this is the 5120x1440 monitor
        if geo.width == 5120 and geo.height == 1440 then
            -- Set custom layout as default for all tags on this screen
            for _, tag in ipairs(s.tags) do
                awful.layout.set(custom_layout, tag)
            end
        end
    end
end

-- Apply layout when screen configuration changes
screen.connect_signal("added", setup_ultrawide_layout)
screen.connect_signal("removed", setup_ultrawide_layout)

-- Apply layout on startup
awesome.connect_signal("startup", setup_ultrawide_layout)

-- Optional: Also apply when switching to tags on the ultrawide monitor
tag.connect_signal("property::selected", function(t)
    if t.selected and t.screen then
        local geo = t.screen.geometry
        if geo.width == 5120 and geo.height == 1440 then
            -- Only change layout if it's not already the custom layout
            if awful.layout.get(t.screen) ~= custom_layout then
                awful.layout.set(custom_layout, t)
            end
        end
    end
end)
