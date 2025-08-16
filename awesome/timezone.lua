require("naughty")
local tz = {}
path = "/home/akingston/.config/awesome/tz"
current_timezone = "America/New_York"

function read_tz()
    local file, err = io.open(path, r)
    if file then 
        current_timezone = file:read("*all")
        file:close()
    end 
end

function tz.set_timezone(tz)
    current_timezone = tz
    local file, err = io.open(path, r)
    if file then 
        err = file:write(current_timezone)
        if err ~= nil then
            naughty.notify({text = err})
        end
        file:close()
    end 
end 

function tz.get_timezone()
    return current_timezone
end

return tz
