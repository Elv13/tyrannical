-- This file is used to store former Tyrannical features now part
-- of upstream. They are kept to support the older versions
local capi = {client = client , tag    = tag   , awesome = awesome,
              screen = screen , mouse  = mouse                    }
local awful = require("awful")

-- Check is Awesome is 3.5.3+
if capi.awesome.startup == nil then
    -- Monkey patch a bug fixed in 3.5.3
    awful.tag.setscreen = function(tag,screen)
        if not tag or type(tag) ~= "tag" then return end
        awful.tag._setscreen(tag,screen)
        for k,c in ipairs(tag:clients()) do
            c.screen = screen or 1 --Move all clients
            c:tags({tag}) --Prevent some very strange side effects, does create some issue with multitag clients
        end
        awful.tag.history.restore(tag.screen,1)
    end
else
    -- Restore the old behavior in newer Awesome
    require("tyrannical.extra.request")
end

awful.tag.swap = function(tag1,tag2)
    local idx1,idx2,scr2 = awful.tag.getidx(tag1),awful.tag.getidx(tag2),awful.tag.getscreen(tag2)
    awful.tag.setscreen(tag2,awful.tag.getscreen(tag1))
    awful.tag.move(idx1,tag2)
    awful.tag.setscreen(tag1,scr2)
    awful.tag.move(idx2,tag1)
end