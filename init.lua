local setmetatable   = setmetatable
local print  , pairs = print  , pairs
local ipairs , type  = ipairs , type
local string , unpack= string , unpack or table.unpack
local awful = require("awful")

local capi,sn_callback = {client = client, tag = tag, awesome = awesome,
    screen = screen, mouse = mouse}, awful.spawn.snid_buffer or {}

-------------------------------INIT------------------------------

local module,c_rules,tags_hash,settings,fallbacks = {},{class={},instance={}},{},{tag={},client={}},{}

----------------------TYRANNICAL LOGIC--------------------------

--Called when a tag is selected/unselected
local function on_selected_change(tag,data)
    if data and data.exec_once and tag.selected then
        for _,v in ipairs(type(data.exec_once) == "string" and {data.exec_once} or data.exec_once) do
            awful.spawn.with_shell("ps -ef | grep -v grep | grep '" .. v .. "' > /dev/null || (" .. v .. ")")
        end
    end
end

local function get_class(c)
    return awful.client.property.get(c, "overwrite_class") or c.class or "N/A"
end

local function get_screen_idx(s)
    return type(s) == "number" and s or s.index
end

local function scr_exists(s)
    local t = type(s)
    return (t == "number" and s > 0 and s <= capi.screen.count())
        or t == "screen" or (t == "table" and s.workarea)
end

--Load tags, this cannot be undone
local function load_tags(tyrannical_tags)
    for k,v in ipairs(tyrannical_tags) do
        if v.init ~= false then
            if type(v.screen) == "table" then
                local screens = v.screen --TODO remove
                for k2,v2 in pairs(screens) do
                    if (type(v2) == "number" and v2 or v2.index) <= capi.screen.count() then
                        v.screen = v2 --TODO remove
                        awful.tag.add(v.name,v,{screen = v2}).is_template = true
                    end
                end
                v.screen = screens --TODO remove
            elseif (v.screen and (type(v.screen) == "number" and v.screen or v.screen.index) or 1) <= capi.screen.count() then
                awful.tag.add(v.name,v).is_template = true
            end
        elseif v.volatile == nil then
            v.volatile = true
        end
        for _,prop in ipairs {"class","instance"} do
            if v[prop] and c_rules[prop] then
--                 for low in (function() local i=0; return function() i=i+1; return prop[i] and prop[i]:lower() end end)() do --TODO fix
                for i=1,#v[prop] do
                    local low = string.lower(v[prop][i])
                    local tmp = c_rules[prop][low] or {tags={},properties={}}
                    tmp.tags[#tmp.tags+1] = awful.util.table.hasitem(tmp.tags,v) == nil and v or nil --Avoid duplicates
                    c_rules[prop][low] = tmp
                end
            end
        end
        tags_hash[v.name or "N/A"] = v
    end
end

--Load property
local function load_property(name,property)
    for k2,v2 in pairs(property) do --TODO make an iterator?
        local key_type = type(k2)
        local low = string.lower(key_type == "number" and v2 or k2)
        c_rules.class[low] = c_rules.class[low] or {name=low,tags={},properties={}}
        c_rules.class[low].properties[name] = key_type == "number" and true or v2
    end
end

local function has_selected(tags, screen)
    if #tags == 0 then return false end

    for _, t in ipairs(screen.selected_tags) do
        if awful.util.table.hasitem(tags, t) then return true end
    end

    return false
end

function awful.rules.delayed_properties.master(c, value)
    if not value then return end

    awful.client.setmaster(c)

    -- Some smarter layouts may implement this directly
    c.master = true
end

function awful.rules.delayed_properties.slave(c, value)
    if not value then return end

    awful.client.setslave(c)

    -- Some smarter layouts may implement this directly
    c.slave = true
end

function module.focus_client(c,properties)

    if (((not c.transient_for) or (c.transient_for==capi.client.focus) or (not settings.block_children_focus_stealing)) and (not c.no_autofocus)) then
        local tags = c:tags()

        if #tags > 0 and not has_selected(tags, c.screen) and not tags[1].no_focus_stealing_in then
            local t = c:tags()[1]
            if t.no_tag_deselect then
                t.selected = true
            else
                t:view_only()
            end
        end

        capi.client.focus = c
        c:raise()
        return true
    end
end

--Apply all properties
local function apply_properties(c, props, callbacks)

    local force_intrusive = settings.force_odd_as_intrusive
        and c.type ~= "normal"

    local is_intrusive = force_intrusive
        or type(props.intrusive) == "function" and props.intrusive(c)
        or props.intrusive

    if props.tag or props.tags or props.new_tag then
        is_intrusive = false
    end

    local has_tag = props.tag or props.new_tag or props.tags
    --Check if the client should be added to an existing tag (or tags)
    if (not has_tag) and is_intrusive then
        local tag = capi.mouse.screen.selected_tag
            or capi.mouse.screen.tags[1]

        if tag and not tag.selected then
            tag:view_only()
        end

        if tag then --Can be false if there is no tags
            props.tag, props.tags, props.intrusive = tag, nil, false
        end
    end

    awful.rules.execute(c, props, callbacks)
end

local function select_screen(tag)
    local s

    -- If there is a table of screen, check if it contains the mouse one
    if type(tag.screen) =="table" and tag.screen[1] then
        for k, ss in ipairs(tag.screen) do
            ss = type(ss) == "number" and ss <= capi.screen.count() and ss or nil
            if ss and capi.screen[ss] == awful.screen.focused() then
                s = ss
            end
        end
        s = s or capi.screen[tag.screen[1]]
    else
        s = scr_exists(tag.screen) and capi.screen[tag.screen] or nil
    end

    -- If the tag.force_screen is set, then obey
    if (tag.force_screen and s) or (s and settings.favor_focused == false) then
        return s
    end

    -- By default, Tyrannical prefer to use the focused screen to place new tags
    -- This override some other settings, but is more pleasant to use.
    return awful.screen.focused()
end

--Match client
local function match_client(c, forced_tags, hints)
    -- Don't prevent tags from being drag and dropped between screens
    if hints and hints.reason == "screen" then
        c:tags {c.screen.selected_tag}
        return true
    end

    if (not c) or #c:tags() > 0 then return end

    local props = c.startup_id and sn_callback[tostring(c.startup_id)] or {}

    local low_i = string.lower(c.instance or "N/A")
    local low_c = string.lower(get_class(c))
    local tags  = props.tags or {props.tag}

    local rules = c_rules.instance[low_i] or c_rules.class[low_c]

    if #tags == 0 and c.transient_for and (capi.mouse.screen or (rules and rules.properties.intrusive_popup)) then
        c.sticky = c.transient_for.sticky or false
        c:tags(awful.util.table.join(c.transient_for:tags(),(rules and rules.properties.intrusive_popup) and c.screen.selected_tags))
        return module.focus_client(c,props)
    elseif forced_tags then
        return module.focus_client(c,props)
    elseif rules then
        --Add to matches
        local tags_src,fav_scr,c_src,mouse_s = {},false,c.screen,capi.mouse.screen
        for j=1,#(#tags == 0 and rules.tags or {}) do
            local tag,cache = rules.tags[j],rules.tags[j].screen
            tag.instances = tag.instances or setmetatable({}, { __mode = 'v' })

            tag.screen = select_screen(tag)

            match = tag.instances[get_screen_idx(tag.screen)]
            tag.screen = tag.screen and get_screen_idx(tag.screen) or nil
            local max_clients = match and (type(match.max_clients) == "function" and match.max_clients(c,match) or match.max_clients) or 999
            if (not match and not (fav_scr == true and mouse_s ~= tag.screen)) or (max_clients <= #match:clients()) then
                local t = awful.tag.add(tag.name,tag)
                t.volatile = match and (max_clients ~= nil) or tag.volatile
                t.is_template = true
            end
            tags_src[tag.screen],fav_scr = tags_src[tag.screen] or {},fav_scr or (tag.screen == mouse_s) --Reset if a better screen is found
            tags_src[tag.screen][#tags_src[get_screen_idx(tag.screen)]+1] = tag.instances[get_screen_idx(tag.screen)]
            tag.screen = cache
        end
        for k,t in ipairs(tags_src[mouse_s] or tags_src[c_src] or select(2,next(tags_src)) or awful.util.table.join(unpack(tags_src))) do
            tags[#tags+1] = t.locked ~= true and t.activated and t or nil --Do not add to locked tags
        end
        c.screen = tags[1] and tags[1].screen or c_src
        if #tags > 0 then
            c:tags(tags)
            return module.focus_client(c,props)
        end
    end

    --Add to the current tag if not exclusive
    local cur_tag = c.screen.selected_tag
    if cur_tag and cur_tag.exclusive ~= true and cur_tag.locked ~= true then
        c:tags({cur_tag})
        return module.focus_client(c,props)
    end

    --Add to the fallback tags
    if #c:tags((function(arr) for k,v in ipairs(fallbacks) do
                                  arr[#arr+1]=v.screen == c.screen and v or nil
                              end; return arr
    end)({})) > 0 then -- Select the first fallback tag if the current tag isn't a fallback
        return module.focus_client(c,props)
    end
    --Last resort, create a new tag
    c_rules.class[low_c] = c_rules.class[low_c] or {tags={},properties={}}
    local tmp,tag = c_rules.class[low_c],awful.tag.add(get_class(c),{name=get_class(c),onetimer=true,volatile=true,exclusive=true,screen=(c.screen.index <= capi.screen.count())
      and c.screen or capi.screen.primary or capi.screen[1],layout=settings.tag.layout or settings.default_layout or awful.layout.suit.max})
    tmp.tags[#tmp.tags+1] = {name=get_class(c),instances = setmetatable({[get_screen_idx(c.screen)]=tag}, { __mode = 'v' }),volatile=true,screen=c.screen,exclusive=true}
    c:tags({tag})
    return module.focus_client(c,props)
end

capi.client.disconnect_signal("request::tag", awful.ewmh.tag)
capi.client.connect_signal("request::tag", match_client)

capi.client.connect_signal("untagged", function (c, t)
    if t.volatile == true and #t:clients() == 0 then
        local rules = c_rules.class[string.lower(get_class(c))]
        c_rules.class[string.lower(get_class(c))] = (t.onetimer ~= true or c.class == nil) and rules or nil --Prevent "last resort tags" from persisting
        for j=1,#(rules and rules.tags or {}) do
            rules.tags[j].instances[get_screen_idx(c.screen)] = rules.tags[j].instances[get_screen_idx(c.screen)] ~= t and rules.tags[j].instances[get_screen_idx(c.screen)] or nil
        end
--         awful.tag.delete(t)
    end
end)

awful.tag._add = awful.tag.add

awful.tag.add = function(tag,props,override)
    props.screen,props.instances = props.screen or capi.mouse.screen,props.instances or setmetatable({}, { __mode = 'v' })
    props.master_width_factor,props.layout = props.master_width_factor or settings.tag.master_width_factor or settings.master_width_factor,props.layout or settings.default_layout or awful.layout.max
    local t = awful.tag._add(tag,awful.util.table.join(settings.tag,props,override))
    fallbacks[#fallbacks+1] = props.fallback and t or nil
    t:connect_signal("property::selected", function(t) on_selected_change(t,props or {}) end)
    t.selected = props.selected or false
    props.instances[get_screen_idx(props.screen)] = t
    return t
end

capi.tag.connect_signal("property::fallback",function(t)
    fallbacks[awful.util.table.hasitem(fallbacks, t) or (#fallbacks+1)] = t.fallback and t or nil
end)

local function contain_screen(tab, s)
    for _, v in ipairs(tab) do
        if type(v) ~= "number" or v <= capi.screen.count() then
            v = capi.screen[v]
            if v == s then
                return true
            end
        end
    end

    return false
end

-- Add init tags to newly connected screens
awful.screen.connect_for_each_screen(function(s)
    for _, def in pairs(tags_hash) do
        if def.init then
            if def.screen and (type(def.screen) == "table" and contain_screen(def.screen, s))
              or (type(def.screen) == "number" and def.screen <= capi.screen.count())
              or (type(def.screen) == "screen") then
                local real_s = def.screen
                def.screen = s
                awful.tag.add(def.name,def).is_template = true
                def.screen = real_s
            end
        end
    end

    -- Restore old tags to their original screen
    for ss in capi.screen do
        for _, t in ipairs(ss.tags) do
            if t.saved_from == s.index then
                t.screen = s
            end
        end
    end
end)

-- Handle events such as screen being removed
capi.tag.connect_signal("request::screen", function(t)
    -- Only salvage used tags
    if #t:clients() > 0 then
        -- If the same class of tag exist on another screen, use that
        if t.is_template and t.instances then
            local new_tag
            for k, t in pairs(t.instances) do
                if k ~= t.screen.index and k <= capi.screen.count() then
                    new_tag = capi.screen[k]
                    break
                end
            end

            if new_tag then
                for _, c in ipairs(t:clients()) do
                    c:tags{new_tag}--TODO batch this to if a client is on 2 tags, it doesn't get removed from the other
                end

                -- The tag will be deleted by awful.tag
                return
            end
        end

        local new_screen = capi.screen.primary or awful.screen.focused() --TODO be smarter

        -- In case the screen comes back, save the old index
        t.saved_from = t.screen.index

        -- Move the tag to an existing screen
        t.selected = false
        t.screen = new_screen
    end
end)

capi.client.disconnect_signal("manage", awful.rules.apply)
capi.client.disconnect_signal("spawn::completed_with_payload", awful.rules.completed_with_payload_callback)
capi.client.disconnect_signal("manage",awful.spawn.on_snid_callback)

--- Replace the default handler to take into account Tyrannical properties
function awful.rules.apply(c)
    local callbacks, props = {}, {}

    -- Add the rules properties
    for _, entry in ipairs(awful.rules.matching_rules(c, awful.rules.rules)) do
        awful.util.table.crush(props,entry.properties or {})

        if entry.callback then
            table.insert(callbacks, entry.callback)
        end
    end

    -- In case the class is overwriten
    local low_c = props.overwrite_class or string.lower(get_class(c))
    local low_i = string.lower(c.instance or "N/A")

    -- Add Tyrannical properties
    local props_src = (c_rules.instance[low_i]
        or c_rules.class[low_c] or {}).properties
        or {}

    awful.util.table.crush(props,props_src)

    -- Add startup_id overridden properties
    if c.startup_id and awful.spawn.snid_buffer[c.startup_id] then
        local snprops, sncb = unpack(awful.spawn.snid_buffer[c.startup_id])

        -- The SNID tag(s) always have precedence over the rules one(s)
        if snprops.tag or snprops.tags or snprops.new_tag then
            props.tag, props.tags, props.new_tag, props.intrusive = nil, nil, nil, false
        end

        awful.util.table.crush(props,snprops)
        awful.util.table.merge(callbacks, sncb)
    end

    apply_properties(c,props, callbacks)
end

capi.client.connect_signal("manage", awful.rules.apply)

capi.client.disconnect_signal("request::activate",awful.ewmh.activate)
capi.client.connect_signal("request::activate",function(c,reason)
    -- Always grant those request as it probably mean that it is a modal dialog
    if c.transient_for and capi.client.focus == c.transient_for then
        capi.client.focus = c
        c:raise()
    -- If it is not modal, then use the normal code path
    elseif reason == "rule" or reason == "rules" or reason == "ewmh" then
        module.focus_client(c)
    -- Tyrannical doesn't have enough information, grant the request
    else
        capi.client.focus = c
        c:raise()
    end
end)


--------------------------OBJECT GEARS---------------------------
local getter = {properties   = setmetatable({}, {__newindex = function(table,k,v) load_property(k,v) end}),
                settings     = settings, tags_by_name = tags_hash, sn_callback = sn_callback}
local setter = {tags         = load_tags}

return setmetatable(module,{__index=function(t,k) return getter[k] end,__newindex=function(t,k,v) if setter[k] then return setter[k](v) end end})
