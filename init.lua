local setmetatable   = setmetatable
local print  , pairs = print  , pairs
local ipairs , type  = ipairs , type
local string         = string
local awful = require("awful")

local capi = {client = client , tag    = tag    ,
              screen = screen , mouse  = mouse  }

module("tyranic")

-------------------------------INIT------------------------------

for _,sig in ipairs({"property::exclusive","property::init","property::volatile","property::focus_on_new","property::instances","property::match","property::class"})do
    capi.tag.add_signal(sig)
end

-------------------------------DATA------------------------------

local class_client,matches_client = {},{}

--------------------------TYRANIC LOGIC--------------------------

--Turn tags -> matches into matches -> tags
local function fill_tyranic(tab_in,tab_out,value)
    if tab_in and tab_out then
        for i=1,#tab_in do
            local low = string.lower(tab_in[i])
            local tmp = tab_out[low] or {tags={},properties={}}
            value.instances = value.instances or {}
            tmp.tags[#tmp.tags+1] = value
            tab_out[low] = tmp
        end
    end
end

--Load tags, this cannot be undone
local function load_tags(tyranic_tags)
    for k,v in ipairs(tyranic_tags) do
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
        fill_tyranic(v.class,class_client,v)
        fill_tyranic(v.match,matches_client,v)
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
        --Set other properties
        for k,v in pairs(rules.properties) do
            c[k] = v
        end
        --Add to the current tag if the client is intrusive, ignore exclusive
        if rules.properties.intrusive == true then
            local tag = awful.tag.selected(c.screen)
            if tag then
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
                c.screen = tag_tmp.screen
                tag_tmp.instances[c.screen or 1] = awful.tag.add(tag_tmp.name,tag_tmp)
                tag_tmp.screen = cache
            end
            tags[#tags+1] = tag_tmp.instances[c.screen or 1]
        end
        if #tags > 0 then
            c:tags(tags)
            if awful.tag.getproperty(tags[1],"focus_on_new") ~= false then
                awful.tag.viewonly(tags[1])
            end
            return
        end
        --TODO post_match
    end
    --Add to the current tag if not exclusive
    --TODO
    --Last resort, create a new tag
    class_client[low] = class_client[low] or {tags={},properties={}}
    local tmp,tag = class_client[low],awful.tag.add(c.class,{name=c.class,volatile=true,screen=c.screen})
    tmp.tags[#tmp.tags+1] = {name=c.class,instances = {tag},volatile=true,screen=c.screen}
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
awful.tag.withcurrent = function(c, startup)
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
        for k,v in pairs(tyranic_properties) do
            load_property(k,v)
        end
    end
end

setmetatable(_M, { __call = function(_, ...) return end , __index = getter, __newindex = setter})