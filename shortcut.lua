local capi      = {root=root,client=client,tag=tag,mouse=mouse}
local ipairs    = ipairs
local unpack    = unpack
local awful = require("awful")
local aw_util   = require( "awful.util"   )
local aw_spawn  = require( "awful.spawn"  )
local aw_tag    = require( "awful.tag"    )
local aw_client = require( "awful.client" )
local aw_layout = require( "awful.layout" )
local aw_key    = require( "awful.key"    )
local aw_prompt = require( "awful.prompt" )
local glib      = require( "lgi"          ).GLib

local shortcuts = {}

local function get_current_screen()
    if capi.client.focus and capi.client.focus.screen == capi.mouse.screen then
        return capi.mouse.screen
    elseif (capi.mouse.screen.selected_tag and #capi.mouse.screen.selected_tag:clients() == 0) or (not capi.client.focus) then
        return capi.mouse.screen
    end
    return capi.client.focus.screen
end

-- Delete a tag as of 3.5.5, this have a few issue. Patches are on their way
function shortcuts.delete_tag()
    local t = get_current_screen().selected_tag
    if not t then return end
    t:delete()
end

-- Create a new tag at the end of the list
function shortcuts.new_tag()
    aw_tag.add("NewTag", {
        screen= get_current_screen()
    }):view_only()
end

function shortcuts.new_tagwith_name()
    aw_prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(name)
            if not name or #name == 0 then
                return
            else
                aw_tag.add(name, {
                    screen= get_current_screen()
                }):view_only()
            end
        end
    }
end

function shortcuts.new_tag_with_focussed()
    local c = capi.client.focus
    if not c then return end

    local t = aw_tag.add(c.class, {
        screen   = get_current_screen(),
        layout   = aw_layout.suit.tile,
        volatile = true
    })

    c:tags(aw_util.table.join(c:tags(), {t}))

    t:view_only()
end

function shortcuts.move_to_new_tag()
    local c = capi.client.focus
    if not c then return end

    local t = aw_tag.add(c.class, {
        screen = get_current_screen()
    })

    c:tags({t})
    t:view_only()
end

local function index_in_list(tag, tagslist)
    for k,v in pairs(tagslist) do 
        if v == tag then return k end
    end
end

function shortcuts.move_to_next_tag()
    local c = capi.client.focus
    if not c then return end

    local tag = awful.screen.focused().selected_tag
    local tags = awful.screen.focused().tags
    local idx = index_in_list(tag, tags)

    local next_tag = tags[idx+1]
    if not next_tag then return end

    c:tags({next_tag})
    next_tag:view_only()
end

function shortcuts.move_to_prev_tag()
    local c = capi.client.focus
    if not c then return end

    local tag = awful.screen.focused().selected_tag
    local tags = awful.screen.focused().tags
    local idx = index_in_list(tag, tags)

    local prev_tag = tags[idx-1]
    if not prev_tag then return end

    c:tags({prev_tag})
    prev_tag:view_only()
end

function shortcuts.rename_tag_to_focussed()
    if not capi.client.focus then return end

    local t = capi.client.focus.screen.selected_tag
    if not t then return end

    t.name = capi.client.focus.class
end

function shortcuts.rename_tag()
    aw_prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(new_name)
            if not new_name or #new_name == 0 then
                return
            else
                local t = capi.mouse.screen.selected_tag
                if t then
                    t.name = new_name
                end
            end
        end
    }
end

function shortcuts.term_in_current_tag()
    aw_spawn(terminal, {
        tag    = get_current_screen().selected_tag,
        slave  = true,
        screen = get_current_screen()
    })
end

function shortcuts.new_tag_with_term()
    aw_spawn(terminal, {
        new_tag = {
            volatile = true,
            screen   = get_current_screen()
        }
    })
end

function shortcuts.fork_tag()
    local t = get_current_screen().selected_tag
    if not t then return end

    local clients = t:clients()
    local t2 = aw_tag.add(t.name,aw_tag.getdata(t))

    t2:clients(clients)
    t2:view_only()
end

function shortcuts.aero_tag()
    local c = capi.client.focus
    if not c then return end

    local c2 = aw_client.focus.history.list[2]
    if (not c2) or c2 == c then return end

    local t = aw_tag.add("Aero", {
        screen = c.screen,
        layout = aw_layout.suit.tile,
        master_width_factor = 0.5
    })

    t:clients({c,c2})

    t:view_only()
end

local function register_keys()
    -- local keys = {}
    -- -- Comment the lines of the shortcut you don't want
    -- for _,data in  ipairs {
    --     {{ modkey            }, "d"     , delete_tag            },
    --     {{ modkey            }, "n"     , new_tag               },
    --     {{ modkey, "Shift"   }, "n"     , new_tag_with_focussed },
    --     {{ modkey, "Mod1"    }, "n"     , move_to_new_tag       },
    --     {{ modkey, "Mod1"    }, "r"     , rename_tag_to_focussed},
    --     {{ modkey, "Shift"   }, "r"     , rename_tag            },
    --     {{ modkey, "Mod1"    }, "Return", term_in_current_tag   },
    --     {{ modkey, "Control" }, "Return", new_tag_with_term     },
    --     {{ modkey, "Control" }, "f"     , fork_tag              },
    --     {{ modkey            }, "a"     , aero_tag              },
    -- } do
    --     keys[#keys+1] = aw_key(data[1], data[2], data[3])
    -- end
    -- capi.root.keys(aw_util.table.join(capi.root.keys(),unpack(keys)))
end
glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, register_keys)

return shortcuts