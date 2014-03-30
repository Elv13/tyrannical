local capi = {client=client,awesome=awesome}
local ewmh = require("awful.ewmh")
local tyrannical = nil

-- Use Tyrannical policies instead of the default ones
capi.client.disconnect_signal("request::activate",ewmh.activate)
capi.client.connect_signal("request::activate",function(c)
    if not tyrannical then
        tyrannical = require("tyrannical")
    end
    local sel_tags = nil --TODO check if the current tag prevent _out stealing
    local tags = c:tags()
--     for k,t in ipairs(tags) do
        --TODO check if one of them is selected
--     end
    capi.client.focus = c
    c:raise()
end)


capi.client.disconnect_signal("request::tag", ewmh.tag)
capi.client.connect_signal("request::tag", function(c)
    if capi.awesome.startup then
        --TODO create a tag on that screen
    else
        --TODO block invalid requests, let Tyrannical do its job
        local tags = c:tags()
        if #tags == 0 then
            --TODO cannot happen
        end
    end
end)


--lib/awful/tag.lua.in:capi.tag.connect_signal("request::select", tag.viewonly)