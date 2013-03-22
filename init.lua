local setmetatable   = setmetatable
local print  , pairs = print  , pairs
local ipairs , type  = ipairs , type
local string         = string
local awful = require("awful")

local capi = {client = client , tag    = tag    ,
              screen = screen , mouse  = mouse  }

local module = {}

-------------------------------INIT------------------------------

local signals = {
  "property::exclusive"    , "property::init"       , "property::volatile" ,
  "property::focus_new"    , "property::instances"  , "property::match"    ,
  "property::class"        , "property::spawn"      , "property::position" ,
  "property::force_screen" , "property::max_clients", "property::exec_once",
  "property::clone_on"     , "property::clone_of"
}
for _,sig in ipairs(signals) do
    capi.tag.add_signal(sig)
end

-------------------------------DATA------------------------------

local class_client,matches_client = {},{}

--------------------------TYRANIC LOGIC--------------------------

--Called when a tag is selected/unselected
local function on_selected_change(tag,data)
    if data.exec_once and tag.selected and not data._init_done then
        for k,v in ipairs(type(data.exec_once) == "string" and {data.exec_once} or data.exec_once) do
            awful.util.spawn(v, false)
        end
        data._init_done = true
    end
end

--Turn tags -> matches into matches -> tags
local function fill_tyrannical(tab_in,tab_out,value)
    if tab_in and tab_out then
        for i=1,#tab_in do
            local low = string.lower(tab_in[i])
            local tmp = tab_out[low] or {tags={},properties={}}
            value.instances=  value.instances or {}
            tmp.tags[#tmp.tags+1] = value
            tab_out[low] = tmp
        end
    end
end

--Load tags, this cannot be undone
local function load_tags(tyrannical_tags)
    for k,v in ipairs(tyrannical_tags) do
        if v.init ~= false then
            v.instances = {}
            local stype = type(v.screen)
            if stype == "table" then
                for k2,v2 in pairs(v.screen) do
                    if v2 <= capi.screen.count() then
                        v.screen = v2
                        v.instances[v2] = awful.tag.add(v.name,v)
                    end
                end
            elseif (v.screen or 1) <= capi.screen.count() then
                v.instances[v.screen or 1] = awful.tag.add(v.name,v)
            end
        elseif v.volatile == nil then
            v.volatile = true
        end
        fill_tyrannical(v.class,class_client,v)
        fill_tyrannical(v.match,matches_client,v)
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

--Match client
local function match_client(c, startup)
    if not c then return end
    local low = string.lower(c.class or "N/A")
    local rules = class_client[low]
    if rules then
        --Force floating state if necessary
        if rules.properties.floating ~= nil then
            awful.client.floating.set(c, rules.properties.floating)
        end
        --Center client
        if rules.properties.centered == true then
            awful.placement.centered(c, nil)
        end
        --Focus new client
        if rules.properties.focus_new ~= false then
            capi.client.focus = c
        end
        --Set other properties
        for k,v in pairs(rules.properties) do
            c[k] = v
        end
        --Add to the current tag if the client is intrusive, ignore exclusive
        if rules.properties.intrusive == true then
            local tag = awful.tag.selected(c.screen)
            if not tag then
                awful.tag.viewonly(awful.tag.gettags(c.screen)[1])
            end
            tag = awful.tag.selected(c.screen)
            if tag then --Can be false if there is no tags
                c:tags({tag})
                return
            end
        end
        --TODO pre_match
        --Add to matches
        local tags = {}
        for j=1,#(rules.tags or {}) do
            local tag_tmp = rules.tags[j]
            if not tag_tmp.instances[c.screen or 1] then
                local cache = tag_tmp.screen
                tag_tmp.screen = tag_tmp.force_screen == true and tag_tmp.screen or c.screen
                tag_tmp.screen = (tag_tmp.screen <= capi.screen.count()) and tag_tmp.screen or 1
                c.screen = tag_tmp.screen
                tag_tmp.instances[(c.screen <= capi.screen.count()) and tag_tmp.screen or 1] = awful.tag.add(tag_tmp.name,tag_tmp)
                tag_tmp.screen = cache
            end
            tags[#tags+1] = tag_tmp.instances[(c.screen <= capi.screen.count()) and c.screen or 1]
        end
        if #tags > 0 then
            c:tags(tags)
            if awful.tag.getproperty(tags[1],"focus_new") ~= false then
                awful.tag.viewonly(tags[1])
            end
            return
        end
        --TODO post_match
    end
    --Add to the current tag if not exclusive
    local cur_tag = awful.tag.selected(c.screen)
    if awful.tag.getproperty(cur_tag,"exclusive") ~= true then
        return c:tags({cur_tag})
    end
    --Last resort, create a new tag
    class_client[low] = class_client[low] or {tags={},properties={}}
    local tmp,tag = class_client[low],awful.tag.add(c.class,{name=c.class,volatile=true,screen=(c.screen <= capi.screen.count()) and c.screen or 1,layout=awful.layout.suit.max})
    tmp.tags[#tmp.tags+1] = {name=c.class,instances = {[c.screen]=tag},volatile=true,screen=c.screen}
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

-- awful.tag.withcurrent = function() end --Disable automatic tag insertion
awful.tag.withcurrent,awful.tag._add  = function(c, startup)
    local tags,old_tags = {},c:tags()
    --Safety to prevent
    for k, t in ipairs(old_tags) do
        if awful.tag.getscreen(t) == c.screen then
            tags[#tags+1] = t
        end
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
    local t = awful.tag._add(tag,props)
    if awful.tag.getproperty(t,"clone_on") and awful.tag.getproperty(t,"clone_on") ~= t.screen then
        local t3 = awful.tag._add(tag,{screen = awful.tag.getproperty(t,"clone_on"), clone_of = t,icon=awful.tag.geticon(t)})
        --TODO prevent clients from being added to the clone
    end
    t:connect_signal("property::selected", function(t) on_selected_change(t,props) end)
    return t
end,awful.tag.setscreen

awful.tag.setscreen,awful.tag._viewonly = function(tag,screen) --Why this isn't by default...
    awful.tag.history.restore(tag.screen,1)
    awful.tag._setscreen(tag,screen)
    for k,c in ipairs(tag:clients()) do
        c.screen = screen or 1 --Move all clients
    end
end,awful.tag.viewonly

awful.tag.viewonly = function(t)
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
local properties = {}
setmetatable(properties, {__newindex = function(table,k,v) load_property(k,v) end})

local function getter (table, key)
    if key == "properties" then
        return properties
    end
end
local function setter (table, key,value)
    if key == "tags" then
        load_tags(value)
    elseif key == "properties" then
        properties = value
        setmetatable(properties, {__newindex = function(table,k,v) load_property(k,v) end})
        for k,v in pairs(tyrannical_properties) do
            load_property(k,v)
        end
    end
end

return setmetatable(module, { __call = function(_, ...) return end , __index = getter, __newindex = setter})
