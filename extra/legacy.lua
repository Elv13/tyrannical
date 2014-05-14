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

-- Check if adding support for sn-based spawn is necessary
if not awful.spawn then
    awful.spawn = {snid_buffer={}}
    function awful.util.spawn(cmd,sn_rules,callback)
        if cmd and cmd ~= "" then
            local enable_sn = (sn_rules ~= false or callback) and true or true
            if not sn_rules and callback then
                sn_rules = {callback=callback}
            elseif callback then
                sn_rules.callback = callback
            end
            local pid,snid = capi.awesome.spawn(cmd, enable_sn)
            -- The snid will be nil in case of failure
            if snid and type(sn_rules) == "table" then
                awful.spawn.snid_buffer[snid] = sn_rules
            end
            return pid,snid
        end
        -- For consistency
        return "Error: No command to execute"
    end
    local function on_canceled(sn)
        awful.spawn.snid_buffer[sn] = nil
    end
    capi.awesome.connect_signal("spawn::canceled" , on_canceled  )
    capi.awesome.connect_signal("spawn::timeout"  , on_canceled   )
else
    -- Then if it's there, disable the part we don't want
    capi.client.disconnect_signal("manage",awful.spawn.on_snid_callback)
end