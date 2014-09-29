local capi = {client=client,awesome=awesome}
local ewmh = require("awful.ewmh")
local tyrannical = nil

-- Use Tyrannical policies instead of the default ones
capi.client.disconnect_signal("request::activate",ewmh.activate)
capi.client.connect_signal("request::activate",function(c,reason)
    if not tyrannical then
        tyrannical = require("tyrannical")
    end
    -- Always grant those request as it probably mean that it is a modal dialog
    if c.transient_for and capi.client.focus == c.transient_for then
        capi.client.focus = c
        c:raise()
    -- If it is not modal, then use the normal code path
    elseif reason == "rule" or reason == "ewmh" then
        tyrannical.focus_client(c)
    -- Tyrannical doesn't have enough information, grant the request
    else
        capi.client.focus = c
        c:raise()
    end
end)


capi.client.disconnect_signal("request::tag", ewmh.tag)
capi.client.connect_signal("request::tag", function(c)
--     if capi.awesome.startup then
--         --TODO create a tag on that screen
--     else
--         --TODO block invalid requests, let Tyrannical do its job
--         local tags = c:tags()
--         if #tags == 0 then
--             --TODO cannot happen
--         end
--     end
end)


--lib/awful/tag.lua.in:capi.tag.connect_signal("request::select", tag.viewonly)