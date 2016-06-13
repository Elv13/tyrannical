local capi      = {root=root,client=client,tag=tag,mouse=mouse}
local ipairs    = ipairs
local unpack    = unpack
local aw_util   = require( "awful.util"   )
local aw_spawn  = require( "awful.spawn"  )
local aw_tag    = require( "awful.tag"    )
local aw_client = require( "awful.client" )
local aw_layout = require( "awful.layout" )
local aw_key    = require( "awful.key"    )
local aw_prompt = require( "awful.prompt" )
local glib      = require( "lgi"          ).GLib

local function get_current_screen()
    if capi.client.focus and capi.client.focus.screen == capi.mouse.screen then
	return capi.mouse.screen
    elseif (not aw_tag.selected(capi.mouse.screen)) or (#aw_tag.selected(capi.mouse.screen):clients() == 0) or (not capi.client.focus) then
	return capi.mouse.screen
    end
    return capi.client.focus.screen
end

-- Delete a tag as of 3.5.5, this have a few issue. Patches are on their way
local function delete_tag()
    aw_tag.delete(aw_tag.selected(get_current_screen()) )
end

-- Create a new tag at the end of the list
local function new_tag()
    aw_tag.viewonly(aw_tag.add("NewTag",{screen= get_current_screen() }))
end

local function new_tag_with_focussed()
    local c = capi.client.focus
    local t = aw_tag.add(c.class,{screen= get_current_screen(),layout=aw_layout.suit.tile, volatile=true })
    if c then c:tags(aw_util.table.join(c:tags(), {t})) end
    aw_tag.viewonly(t)
end

local function move_to_new_tag()
    local c = capi.client.focus
    local t = aw_tag.add(c.class,{screen= get_current_screen() })
    if c then
        c:tags({t})
        aw_tag.viewonly(t)
    end
end

local function rename_tag_to_focussed()
    if capi.client.focus then
        local t = aw_tag.selected(capi.client.focus.screen)
        t.name = capi.client.focus.class
    end
end

local function rename_tag()
    aw_prompt.run({ prompt = "New tag name: " },
        mypromptbox[capi.mouse.screen].widget,
        function(new_name)
            if not new_name or #new_name == 0 then
                return
            else
                local screen = capi.mouse.screen
                local t = aw_tag.selected(screen)
                if t then
                    t.name = new_name
                end
            end
        end
    )
end

local function term_in_current_tag()
    aw_spawn(terminal,{intrusive=true,slave=true})
end

local function new_tag_with_term()
    aw_spawn(terminal,{new_tag={volatile = true}})
end

local function fork_tag()
    local s = get_current_screen()
    local t = aw_tag.selected(s)
    if not t then return end
    local clients = t:clients()
    local t2 = aw_tag.add(t.name,aw_tag.getdata(t))
    t2:clients(clients)
    aw_tag.viewonly(t2)
end

local function aero_tag()
    local c = capi.client.focus
    if not c then return end
    local c2 = aw_client.focus.history.list[2]
    if (not c2) or c2 == c then return end
    local t = aw_tag.add("Aero",{screen= c.screen ,layout=aw_layout.suit.tile,mwfact=0.5})
    t:clients({c,c2})

    t:view_only()
end

local function register_keys()
    local keys = {}
    -- Comment the lines of the shortcut you don't want
    for _,data in  ipairs {
        {{ modkey            }, "d"     , delete_tag            },
        {{ modkey            }, "n"     , new_tag               },
        {{ modkey, "Shift"   }, "n"     , new_tag_with_focussed },
        {{ modkey, "Mod1"    }, "n"     , move_to_new_tag       },
        {{ modkey, "Mod1"    }, "r"     , rename_tag_to_focussed},
        {{ modkey, "Shift"   }, "r"     , rename_tag            },
        {{ modkey, "Mod1"    }, "Return", term_in_current_tag   },
        {{ modkey, "Control" }, "Return", new_tag_with_term     },
        {{ modkey, "Control" }, "f"     , fork_tag              },
        {{ modkey            }, "a"     , aero_tag              },
    } do
        keys[#keys+1] = aw_key(data[1], data[2], data[3])
    end
    capi.root.keys(aw_util.table.join(capi.root.keys(),unpack(keys)))
end
glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, register_keys)
