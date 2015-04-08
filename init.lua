local setmetatable   = setmetatable
local print  , pairs = print  , pairs
local ipairs , type  = ipairs , type
local string , unpack= string , unpack
local awful = require("awful")
require("tyrannical.extra.legacy")

local capi,sn_callback = {client = client, tag = tag, awesome = awesome,
    screen = screen, mouse = mouse},awful.spawn and awful.spawn.snid_buffer or {}

-------------------------------INIT------------------------------

local signals,module,c_rules,tags_hash,settings,fallbacks,prop = {
  "exclusive"   , "init"      , "volatile"  , "focus_new" , "instances"           ,
  "locked"      , "class"     , "instance"  , "spawn"     , "position"            ,
  "max_clients" , "exec_once" , "clone_on"  , "onetimer"  , "no_focus_stealing"   ,
  "force_screen", "fallback"  , "no_focus_stealing_out"   , "no_focus_stealing_in",
},{},{class={},instance={}},{},{tag={},client={}},{},awful.tag.getproperty

for _,sig in ipairs(signals) do
    capi.tag.add_signal("property::"..sig)
end

----------------------TYRANNICAL LOGIC--------------------------

--Called when a tag is selected/unselected
local function on_selected_change(tag,data)
    if data and data.exec_once and tag.selected then
        for _,v in ipairs(type(data.exec_once) == "string" and {data.exec_once} or data.exec_once) do
            awful.util.spawn_with_shell("ps -ef | grep -v grep | grep '" .. v .. "' > /dev/null || (" .. v .. ")")
        end
    end
end

local function get_class(c)
    return awful.client.property.get(c, "overwrite_class") or c.class or "N/A"
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
        for _,prop in ipairs {"class","instance"} do
            if v[prop] and c_rules[prop] then
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
    for k2,v2 in pairs(property) do
        local key_type = type(k2)
        local low = string.lower(key_type == "number" and v2 or k2)
        c_rules.class[low] = c_rules.class[low] or {name=low,tags={},properties={}}
        c_rules.class[low].properties[name] = key_type == "number" and true or v2
    end
end

--Check all focus policies then change focus (Awesome 3.5.3+)
function module.focus_client(c,properties)
    local properties = properties or (c_rules.instance[string.lower(c.instance or "N/A")] or {}).properties or (c_rules.class[string.lower(get_class(c))] or {}).properties or {}
    if (((not c.transient_for) or (c.transient_for==capi.client.focus) or (not settings.block_children_focus_stealing)) and (not properties.no_autofocus)) then
        if not awful.util.table.hasitem(c:tags(), awful.tag.selected(c.screen or 1)) and (not prop(c:tags()[1],"no_focus_stealing_in")) then
            awful.tag.viewonly(c:tags()[1])
        end
        capi.client.focus = c
        c:raise()
        return true
    end
end

--Apply all properties
local function apply_properties(c,override,normal)
    if not override and not normal then return nil,{} end
    local props,ret = awful.util.table.join(settings.client,normal or {},override,
        override.callback and override.callback(c) or (normal and normal.callback and normal.callback(c)) or {}),nil
    --Set all 'c.something' properties, --TODO maybe eventually move to awful.rules.execute
    for k,_ in pairs(props) do
        c[k] = props[k]
    end
    --Force floating state, if necessary
    if props.floating ~= nil then
        awful.client.floating.set(c, props.floating)
    end
    --Center client
    if props.centered == true then
        awful.placement.centered(c, nil)
    end
    --Set slave or master
    if props.slave == true or props.master == true then
        awful.client["set"..(props.slave and "slave" or "master")](c, true)
    end
    --Check if the client should be added to an existing tag (or tags)
    if props.new_tag then
        ret = c:tags({awful.tag.add(type(props.new_tag)=="table" and props.new_tag.name or c.class,type(props.new_tag)=="table" and props.new_tag or {screen=c.screen or 1})})
    elseif props.tag then
        ret = c:tags(type(props.tag) == "function" and props.tag(c) or (type(props.tag) == "table" and props.tag or { props.tag }))
    elseif props.intrusive == true or (settings.force_odd_as_intrusive and c.type ~= "normal") then
        local tag = awful.tag.selected(c.screen) or awful.tag.viewonly(awful.tag.gettags(c.screen)[1]) or awful.tag.selected(c.screen)
        if tag then --Can be false if there is no tags
            ret = c:tags({tag})
        end
    end
    return ret,props
end

--Match client
local function match_client(c, startup)
    if not c then return end
    local startup = startup == nil and capi.awesome.startup or startup
    local props = c.startup_id and sn_callback[tostring(c.startup_id)] or {}

    local low_i = string.lower(c.instance or "N/A")
    local low_c = string.lower(get_class(c))
    local tags  = props.tags or {props.tag}
    local rules = c_rules.instance[low_i] or c_rules.class[low_c]
    local forced_tags,props = apply_properties(c,props,rules and rules.properties)

    if #tags == 0 and c.transient_for and settings.group_children == true then
        c.sticky = c.transient_for.sticky or false
        c:tags(c.transient_for:tags())
        return module.focus_client(c,props)
    elseif forced_tags then
        return module.focus_client(c,props)
    elseif rules then
        --Add to matches
        local tags_src,fav_scr,c_src,mouse_s = {},false,c.screen,capi.mouse.screen
        for j=1,#(#tags == 0 and rules.tags or {}) do
            local tag,cache = rules.tags[j],rules.tags[j].screen
            tag.instances,has_screen = tag.instances or setmetatable({}, { __mode = 'v' }),(type(tag.screen)=="table" and awful.util.table.hasitem(tag.screen,c_src)~=nil)
            tag.screen = (tag.force_screen ~= true and c_src) or (has_screen and c_src or type(tag.screen)=="table" and tag.screen[1] or tag.screen)
            tag.screen,match = (tag.screen <= capi.screen.count()) and tag.screen or mouse_s,tag.instances[tag.screen]
            local max_clients = match and (type(prop(match,"max_clients")) == "function" and prop(match,"max_clients")(c,match) or prop(match,"max_clients")) or 999
            if (not match and not (fav_scr == true and mouse_s ~= tag.screen)) or (max_clients <= #match:clients()) then
                awful.tag.setproperty(awful.tag.add(tag.name,tag),"volatile",match and (max_clients ~= nil) or tag.volatile)
            end
            tags_src[tag.screen],fav_scr = tags_src[tag.screen] or {},fav_scr or (tag.screen == mouse_s) --Reset if a better screen is found
            tags_src[tag.screen][#tags_src[tag.screen]+1] = tag.instances[tag.screen]
            tag.screen = cache
        end
        for k,t in ipairs(tags_src[mouse_s] or tags_src[c_src] or select(2,next(tags_src)) or awful.util.table.join(unpack(tags_src))) do
            tags[#tags+1] = prop(t,"locked") ~= true and t.activated and t or nil --Do not add to locked tags
        end
        c.screen = tags[1] and awful.tag.getscreen(tags[1]) or c_src
        if #tags > 0 then
            c:tags(tags)
            return module.focus_client(c,props)
        end
    end
    --Add to the current tag if not exclusive
    local cur_tag = awful.tag.selected(c.screen)
    if cur_tag and prop(cur_tag,"exclusive") ~= true and prop(cur_tag,"locked") ~= true then
        c:tags({cur_tag})
        return module.focus_client(c,props)
    end
    --Add to the fallback tags
    if #c:tags((function(arr) for k,v in ipairs(fallbacks) do
                                  arr[#arr+1]=awful.tag.getscreen(v) == c.screen and v or nil
                              end; return arr
    end)({})) > 0 then -- Select the first fallback tag if the current tag isn't a fallback
        return module.focus_client(c,props)
    end
    --Last resort, create a new tag
    c_rules.class[low_c] = c_rules.class[low_c] or {tags={},properties={}}
    local tmp,tag = c_rules.class[low_c],awful.tag.add(get_class(c),{name=get_class(c),onetimer=true,volatile=true,exclusive=true,screen=(c.screen <= capi.screen.count())
      and c.screen or 1,layout=settings.tag.layout or settings.default_layout or awful.layout.suit.max})
    tmp.tags[#tmp.tags+1] = {name=get_class(c),instances = setmetatable({[c.screen]=tag}, { __mode = 'v' }),volatile=true,screen=c.screen,exclusive=true}
    c:tags({tag})
    return module.focus_client(c,props)
end

capi.client.connect_signal("manage", match_client)

capi.client.connect_signal("untagged", function (c, t)
    if prop(t,"volatile") == true and #t:clients() == 0 then
        local rules = c_rules.class[string.lower(get_class(c))]
        c_rules.class[string.lower(get_class(c))] = (prop(t,"onetimer") ~= true or get_class(c) == nil) and rules or nil --Prevent "last resort tags" from persisting
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

awful.tag.add,awful.tag._setscreen,awful.tag._viewonly = function(tag,props)
    props.screen,props.instances = props.screen or capi.mouse.screen,props.instances or setmetatable({}, { __mode = 'v' })
    props.mwfact,props.layout = props.mwfact or settings.tag.mwfact or settings.mwfact,props.layout or settings.default_layout or awful.layout.max
    local t = awful.tag._add(tag,awful.util.table.join(settings.tag,props))
    fallbacks[#fallbacks+1] = props.fallback and t or nil
    t:connect_signal("property::selected", function(t) on_selected_change(t,props or {}) end)
    t.selected = props.selected or false
    props.instances[props.screen] = t
    return t
end,awful.tag.setscreen,awful.tag.viewonly

awful.tag.viewonly = function(t)
    if not t then return end
    if not awful.tag.getscreen(t) then awful.tag.setscreen(capi.mouse.screen) end
    awful.tag._viewonly(t)
end

capi.tag.connect_signal("property::fallback",function(t)
    fallbacks[awful.util.table.hasitem(fallbacks, t) or (#fallbacks+1)] = prop(t,"fallback") and t or nil
end)

--------------------------OBJECT GEARS---------------------------
local getter = {properties   = setmetatable({}, {__newindex = function(table,k,v) load_property(k,v) end}),
                settings     = settings, tags_by_name = tags_hash, sn_callback = sn_callback}
local setter = {tags         = load_tags}

return setmetatable(module,{__index=function(t,k) return getter[k] end,__newindex=function(t,k,v) if setter[k] then return setter[k](v) end end})
