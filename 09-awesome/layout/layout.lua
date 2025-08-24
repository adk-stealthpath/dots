local awful = require("awful")
-- Custom layout for AwesomeWM
-- Add this to your rc.lua

local custom_layout = {}
custom_layout.name = "custom"

function custom_layout.arrange(p)
    local area = p.workarea
    local clients = p.clients
    local num_clients = #clients
    local gap = 10 -- 5px gap between windows
    
    if num_clients == 0 then
        return
    end
    
    local geometries = {}
    
    if num_clients == 1 then
        -- 1 window: centre 100% (no gaps needed for single window)
        geometries[1] = {
            x = area.x,
            y = area.y,
            width = area.width,
            height = area.height
        }
        
    elseif num_clients == 2 then
        -- 2 windows: left 2/3, right 1/3 with gap
        local total_gap = gap
        local left_width = math.floor((area.width - total_gap) * 2/3)
        local right_width = area.width - left_width - total_gap
        
        geometries[1] = {
            x = area.x,
            y = area.y,
            width = left_width,
            height = area.height
        }
        geometries[2] = {
            x = area.x + left_width + gap,
            y = area.y,
            width = right_width,
            height = area.height
        }
        
    elseif num_clients == 3 then
        -- 3 windows: left 1/4, centre 1/2, right 1/4 with gaps
        local total_gaps = gap * 2  -- 2 gaps between 3 windows
        local available_width = area.width - total_gaps
        local left_width = math.floor(available_width * 1/4)
        local centre_width = math.floor(available_width * 1/2)
        local right_width = available_width - left_width - centre_width
        
        geometries[1] = {
            x = area.x,
            y = area.y,
            width = left_width,
            height = area.height
        }
        geometries[2] = {
            x = area.x + left_width + gap,
            y = area.y,
            width = centre_width,
            height = area.height
        }
        geometries[3] = {
            x = area.x + left_width + gap + centre_width + gap,
            y = area.y,
            width = right_width,
            height = area.height
        }
        
    elseif num_clients == 4 then
        -- 4 windows: left 1/4, centre 1/2, right column split with gaps
        local total_h_gaps = gap * 2  -- horizontal gaps
        local available_width = area.width - total_h_gaps
        local left_width = math.floor(available_width * 1/4)
        local centre_width = math.floor(available_width * 1/2)
        local right_width = available_width - left_width - centre_width
        local right_height = math.floor((area.height - gap) / 2)
        
        geometries[1] = {
            x = area.x,
            y = area.y,
            width = left_width,
            height = area.height
        }
        geometries[2] = {
            x = area.x + left_width + gap,
            y = area.y,
            width = centre_width,
            height = area.height
        }
        geometries[3] = {
            x = area.x + left_width + gap + centre_width + gap,
            y = area.y,
            width = right_width,
            height = right_height
        }
        geometries[4] = {
            x = area.x + left_width + gap + centre_width + gap,
            y = area.y + right_height + gap,
            width = right_width,
            height = area.height - right_height - gap
        }
        
    elseif num_clients >= 5 then
        -- 5+ windows: corners are split, centre is full height, with gaps
        local total_h_gaps = gap * 2  -- horizontal gaps
        local available_width = area.width - total_h_gaps
        local side_width = math.floor(available_width / 4)  -- 1/4 of available width
        local centre_width = math.floor(available_width / 2)  -- 1/2 of available width
        local remaining_width = available_width - (side_width * 2) - centre_width
        local half_height = math.floor((area.height - gap) / 2)
        
        -- Top left
        geometries[1] = {
            x = area.x,
            y = area.y,
            width = side_width,
            height = half_height
        }
        -- Bottom left
        geometries[2] = {
            x = area.x,
            y = area.y + half_height + gap,
            width = side_width,
            height = area.height - half_height - gap
        }
        -- Centre
        geometries[3] = {
            x = area.x + side_width + gap,
            y = area.y,
            width = centre_width,
            height = area.height
        }
        -- Top right
        geometries[4] = {
            x = area.x + side_width + gap + centre_width + gap,
            y = area.y,
            width = side_width + remaining_width,
            height = half_height
        }
        -- Bottom right
        geometries[5] = {
            x = area.x + side_width + gap + centre_width + gap,
            y = area.y + half_height + gap,
            width = side_width + remaining_width,
            height = area.height - half_height - gap
        }
        
        -- If there are more than 5 windows, stack them in the remaining spaces
        -- (You can modify this behavior as needed)
        for i = 6, num_clients do
            -- Just stack additional windows on top of the last one for simplicity
            geometries[i] = geometries[5]
        end
    end
    
    -- Apply geometries to clients
    for i, c in ipairs(clients) do
        if geometries[i] then
            c:geometry(geometries[i])
        end
    end
end


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
