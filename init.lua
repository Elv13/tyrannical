local setmetatable   = setmetatable
local print  , pairs = print  , pairs
local ipairs , type  = ipairs , type
local string , unpack= string,unpack
local awful = require("awful")

local capi = {client = client , tag    = tag   , awesome = awesome,
              screen = screen , mouse  = mouse                    }

-------------------------------INIT------------------------------

local signals,module,class_client,tags_hash,settings,sn_callback = {
  "exclusive"   , "init"      , "volatile"  , "focus_new" , "instances"        ,
  "match"       , "class"     , "spawn"     , "position"  , "force_screen"     ,
  "max_clients" , "exec_once" , "clone_on"  , "clone_of"  , "no_focus_stealing",
  "shape_bounding", "no_focus_stealing_out","no_focus_stealing_in"
},{},{},{},{},{}

for _,sig in ipairs(signals) do
    capi.tag.add_signal("property::"..sig)
end

----------------------TYRANNICAL LOGIC--------------------------

--Called when a tag is selected/unselected
local function on_selected_change(tag,data)
    if data and data.exec_once and tag.selected and not data._init_done then
        for k,v in ipairs(type(data.exec_once) == "string" and {data.exec_once} or data.exec_once) do
            awful.util.spawn(v, false)
        end
        data._init_done = true
    end
end

--Load tags, this cannot be undone
local function load_tags(tyrannical_tags)
    for k,v in ipairs(tyrannical_tags) do
        if v.init ~= false then
            local stype = type(v.screen)
            if stype == "table" then
                local screens = v.screen
                for k2,v2 in pairs(screens) do
                    if v2 <= capi.screen.count() then
                        v.screen = v2
                        awful.tag.add(v.name,v)
                    end
                end
                v.screen = screens
            elseif (v.screen or 1) <= capi.screen.count() then
                awful.tag.add(v.name,v)
            end
        elseif v.volatile == nil then
            v.volatile = true
        end
        if v.class and class_client then
            for i=1,#v.class do
                local low = string.lower(v.class[i])
                local tmp = class_client[low] or {tags={},properties={}}
                tmp.tags[#tmp.tags+1] = v
                class_client[low] = tmp
            end
        end
        tags_hash[v.name or "N/A"] = v
    end
end

--Load property
local function load_property(name,property)
    for k2,v2 in pairs(property) do
        local key_type = type(k2)
        local low = string.lower(key_type == "number" and v2 or k2)
        class_client[low] = class_client[low] or {name=low,tags={},properties={}}
        class_client[low].properties[name] = key_type == "number" and true or v2
    end
end

--Apply all properties
local function apply_properties(c,override,normal)
    local prop = awful.util.table.join(normal,override)
    --Set all 'c.something' properties
    for k,_ in pairs(prop) do
        prop[k] = (override[v] ~= nil) and override[k] or normal[k]
        c[k] = prop[k]
    end
    --Force floating state, if necessary
    if prop.floating ~= nil then
        awful.client.floating.set(c, prop.floating)
    end
    --Center client
    if prop.centered == true then
        awful.placement.centered(c, nil)
    end
    --Focus new client
    if prop.focus_new ~= false and (c.transient_for and not settings.block_transient_for_focus_stealing) then
        capi.client.focus = c
    end
    --Add to the current tag if the client is intrusive, ignore exclusive
    if prop.intrusive == true or (settings.force_odd_as_intrusive and c.type ~= "normal") then
        local tag = awful.tag.selected(c.screen)
        if not tag then
            awful.tag.viewonly(awful.tag.gettags(c.screen)[1])
        end
        tag = awful.tag.selected(c.screen)
        if tag then --Can be false if there is no tags
            return c:tags({tag})
        end
    end
end

--Match client
local function match_client(c, startup)
    if not c then return end
    local startup = startup == nil and capi.awesome.startup or startup
    if c.startup_id and sn_callback[c.startup_id] and sn_callback[c.startup_id](c,startup) then return end
    local low = string.lower(c.class or "N/A")
    local rules = class_client[low]
    if c.transient_for and settings.group_children == true then
        c.sticky = c.transient_for.sticky or false
        c:tags(c.transient_for:tags())
        capi.client.focus = c
        return
    elseif rules then
        local ret = apply_properties(c,{},rules.properties)
        if ret then
            if not rules.properties.no_autofocus then
                capi.client.focus = c
            end
            return ret
        end
        --Add to matches
        local tags,tags_src,fav_scr,c_src,mouse_s = {},{},false,c.screen,capi.mouse.screen
        for j=1,#(rules.tags or {}) do
            local tag,cache = rules.tags[j],rules.tags[j].screen
            tag.instances,has_screen = tag.instances or {},(type(tag.screen)=="table" and awful.util.table.hasitem(tag.screen,c_src)~=nil)
            tag.screen = (tag.force_screen ~= true and c_src) or (has_screen and c_src or type(tag.screen)=="table" and tag.screen[1] or tag.screen)
            tag.screen = (tag.screen <= capi.screen.count()) and tag.screen or mouse_s
            if not tag.instances[tag.screen] and not (fav_scr == true and mouse_s ~= tag.screen) then
                awful.tag.add(tag.name,tag)
            end
            tags_src[tag.screen],fav_scr = tags_src[tag.screen] or {},fav_scr or (tag.screen == mouse_s) --Reset if a better screen is found
            tags_src[tag.screen][#tags_src[tag.screen]+1] = tag.instances[tag.screen]
            tag.screen = cache
        end
        tags = tags_src[mouse_s] or tags_src[c_src] or select(2,next(tags_src)) or awful.util.table.join(unpack(tags_src))
        c.screen = tags[1] and awful.tag.getscreen(tags[1]) or c_src
        if #tags > 0 and tags[1] then
            c:tags(tags)
            if awful.tag.getproperty(tags[1],"focus_new") ~= false and not (c.transient_for and settings.block_transient_for_focus_stealing)
              and not awful.tag.getproperty(tags[1],"no_focus_stealing_in") then
                awful.tag.viewonly(tags[1])
--             elseif awful.tag.getproperty(tags[1],"no_focus_stealing") then
--                 c.urgent = true --It is not Tyrannical job to decide if it is urgent or not
            end
            if not rules.properties.no_autofocus then
                capi.client.focus = c
            end
            return
        end
    end
    --Add to the current tag if not exclusive
    local cur_tag = awful.tag.selected(c.screen)
    if cur_tag and awful.tag.getproperty(cur_tag,"exclusive") ~= true then
        c:tags({cur_tag})
        capi.client.focus = c
        return true
    end
    --Last resort, create a new tag
    class_client[low] = class_client[low] or {tags={},properties={}}
    local tmp,tag = class_client[low],awful.tag.add(c.class or "N/A",{name=c.class or "N/A",volatile=true,exclusive=true,screen=(c.screen <= capi.screen.count())
      and c.screen or 1,layout=settings.default_layout or awful.layout.suit.max})
    tmp.tags[#tmp.tags+1] = {name=c.class or "N/A",instances = {[c.screen]=tag},volatile=true,screen=c.screen,exclusive=true}
    c:tags({tag})
    if awful.tag.getproperty(tag,"focus_on_new") ~= false then
        awful.tag.viewonly(tag)
    end
end

capi.client.connect_signal("manage", match_client)

capi.client.connect_signal("untagged", function (c, t)
    if awful.tag.getproperty(t,"volatile") == true and #t:clients() == 0 then
        local rules = class_client[string.lower(c.class or "N/A")]
        for j=1,#(rules and rules.tags or {}) do
            rules.tags[j].instances[c.screen] = rules.tags[j].instances[c.screen] ~= t and rules.tags[j].instances[c.screen] or nil
        end
        awful.tag.delete(t)
    end
end)

awful.tag.withcurrent,awful.tag._add  = function(c, startup)
    local tags,old_tags = {},c:tags()
    --Safety to prevent
    for k, t in ipairs(old_tags) do
        tags[#tags+1] = (awful.tag.getscreen(t) == c.screen) and t or nil
    end
    --Necessary when dragging clients
    if startup == nil and old_tags[1] and old_tags[1].screen ~= c.screen then --nil != false
        local sellist = awful.tag.selectedlist(c.screen)
        if #sellist > 0 then --Use already selected tag
            tags = sellist
        else --Select a tag
            match_client(c, startup)
        end
    end
    c:tags(tags)
end,awful.tag.add

awful.tag.add,awful.tag._setscreen = function(tag,props)
    props.screen,props.instances = props.screen or capi.mouse.screen,props.instances or {}
    props.mwfact,props.layout = props.mwfact or settings.mwfact,props.layout or settings.default_layout or awful.layout.max
    local t = awful.tag._add(tag,props)
    if awful.tag.getproperty(t,"clone_on") and awful.tag.getproperty(t,"clone_on") ~= t.screen then
        local t3 = awful.tag._add(tag,{screen = awful.tag.getproperty(t,"clone_on"), clone_of = t,icon=awful.tag.geticon(t)})
        --TODO prevent clients from being added to the clone
    end
    t:connect_signal("property::selected", function(t) on_selected_change(t,props or {}) end)
    t.selected = props.selected or false
    props.instances[props.screen] = t
    return t
end,awful.tag.setscreen

awful.tag._viewonly = awful.tag.viewonly

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

awful.tag.viewonly = function(t)
    if not t then return end
    if not awful.tag.getscreen(t) then awful.tag.setscreen(capi.mouse.screen) end
    awful.tag._viewonly(t)
    if awful.tag.getproperty(t,"clone_of") then
        awful.tag.swap(t,awful.tag.getproperty(t,"clone_of"))
        awful.tag.viewonly(awful.tag.getproperty(t,"clone_of"))
    end
end

awful.tag.swap = function(tag1,tag2)
    local idx1,idx2,scr2 = awful.tag.getidx(tag1),awful.tag.getidx(tag2),awful.tag.getscreen(tag2)
    awful.tag.setscreen(tag2,awful.tag.getscreen(tag1))
    awful.tag.move(idx1,tag2)
    awful.tag.setscreen(tag1,scr2)
    awful.tag.move(idx2,tag1)
end

--------------------------OBJECT GEARS---------------------------
local getter = {properties   = setmetatable({}, {__newindex = function(table,k,v) load_property(k,v) end}),
                settings     = settings, tags_by_name = tags_hash, sn_callback = sn_callback}
local setter = {tags         = load_tags}

return setmetatable(module,{__index=function(t,k) return getter[k] end,__newindex=function(t,k,v) if setter[k] then return setter[k](v) end end})
