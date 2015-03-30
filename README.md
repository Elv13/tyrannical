Tyrannical—A simple tag managment engine for Awesome
-----------------------------------------------------

### Description
Shifty was great and served us well since the early days of the Awesome 3.\*
series, but just as many aged kid TV stars, it has not grown that well. Many of
its once unique features are now supported by the default ```awful.tag```
engine, adding legacy complexity to the code base and affecting performance.

This is why Tyrannical was created. It is a light rule engine offering pretty
much the same rule configuration, but without all the dynamic tag code. Note
that dynamic tagging is now supported directly by awesome. Tyrannical support
Awesome WM version 3.5 and higher.

#### Tag model

Tyrannical turn awful.rule upside down. Instead of having to define rules for
specific classes or matches, you define an array of tags, each with their own
set of properties and rules. When a new client will arrive, it will be matched
with a set of tags without any client specific configuration.

All tags can have one "current" state:

 * **inclusive:** The default state. All new clients will be allowed
 * **exclusive:** Clients have be part of the allowed classes to be added
 * **locked:** No new clients will be allowed in the tag
 * **fallback:** If a client cannot be added to the current tag, then it will go there

These rules are bypassed by `intrusive` clients. In that case, the client will
be allowed no matter what. If there is no fallback tag and the client cannot be
added to an existing tag, then a new one will be created with the client class
as name. If the tag is set to `volatile`, then it will be destroyed when the
last client is closed. If set to `init`, it will be present by default even if
there is nothing in it.

#### Client properties model

Tyrannical offer a bunch of dynamic table for each properties (see below).
When a class is present in one of those table, clients will be assigned the
properties from the table name. For example, if you add Firefox to
`tyrannical.properties.floating`, then it will float by default. Specific values
can also to other value by using the class name as table key:

```lua
    tyrannical.properties.maximized = {
        amarok = false,
    }
```

#### Focus model

Tyrannical focus model is very fine tuned. It is possible to add rules on how
the focus will be attributes to clients and tags.

**block_children_focus_stealing:** 
This is a fancy X11 name for something very common: modal dialogs and popups.
If this is set to `true`, then a dialog wont be able to steal the focus from
whatever your doing. This is useful for some misbehaving apps such as Firefox
that can decide to show an update popup at the worst possible moment.

**group_children:**
While not directly related to focus, when using with `no_focus_stealing_out`,
it allow new "children" clients to silently be added to their "parent" tag.
A good taglist widgets such as Radical can take care of notifying the user
without disturbing your workflow.

**no_focus_stealing_in:**
When a new client is added to a tag with `no_focus_stealing_in` set to true,
then the tag wont be selected and the current one will be kept.

**no_focus_stealing_out:**
Similar to `no_focus_stealing_in`. If a tag enable this, then the tag will stay
selected no matter what event happen. This is useful for video games and video
players.

**no_autofocus:**
When a class has this flag, then new clients wont be focused when they are
launched. This is useful for download managers or background terminals tasks.

### Installation

This is how to install Tyrannical

```
    mkdir -p ~/.config/awesome
    cd ~/.config/awesome
    git clone https://github.com/Elv13/tyrannical.git
```

Then either use the sample rc.lua or upgrade your existing one.

### Examples

Install [Xephyr](http://www.freedesktop.org/wiki/Software/Xephyr) and run the
following script

```
 sh utils/xephyr.sh start
```

*Note:* The tyrannical repository must be named awesome-tyrannical for the
script to work out of the box.

Also see ```samples.rc.lua``` for a sample.

### Configuration

If you previously used Shifty, you will feel comfortable using Tyrannical. The
only difference is that in Tyrannical class matching is integrated into the tag
configuration section. More advanced rules can be created using
```awful.rules```. Again, Tyrannical was not created to duplicate awful, but to
make dynamic (and static, as a side effect) tagging configuration easier. This
module doesn't require any major initialisation. Compared to shifty, it is much
more transparent.

The first modification is to include the module at the top of your ```rc.lua``` (after ```awful.rules = require("awful.rules")```):
```lua
local tyrannical = require("tyrannical")
```

Then this section have to be replaced:
```lua
-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}
```

by:

```lua
tyrannical.tags = {
    {
        name        = "Term",                 -- Call the tag "Term"
        init        = true,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {1,2},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.tile, -- Use the tile layout
        instance    = {"dev", "ops"},         -- Accept the following instances. This takes precedence over 'class'
        class       = { --Accept the following classes, refuse everything else (because of "exclusive=true")
            "xterm" , "urxvt" , "aterm","URxvt","XTerm","konsole","terminator","gnome-terminal"
        }
    } ,
    {
        name        = "Internet",
        init        = true,
        exclusive   = true,
      --icon        = "~net.png",                 -- Use this icon for the tag (uncomment with a real path)
        screen      = screen.count()>1 and 2 or 1,-- Setup on screen 2 if there is more than 1 screen, else on screen 1
        layout      = awful.layout.suit.max,      -- Use the max layout
        class = {
            "Opera"         , "Firefox"        , "Rekonq"    , "Dillo"        , "Arora",
            "Chromium"      , "nightly"        , "minefield"     }
    } ,
    {
        name = "Files",
        init        = true,
        exclusive   = true,
        screen      = 1,
        layout      = awful.layout.suit.tile,
        exec_once   = {"dolphin"}, --When the tag is accessed for the first time, execute this command
        class  = {
            "Thunar", "Konqueror", "Dolphin", "ark", "Nautilus","emelfm"
        }
    } ,
    {
        name = "Develop",
        init        = true,
        exclusive   = true,
        screen      = 1,
        layout      = awful.layout.suit.max                          ,
        class ={ 
            "Kate", "KDevelop", "Codeblocks", "Code::Blocks" , "DDD", "kate4"}
    } ,
    {
        name        = "Doc",
        init        = false, -- This tag wont be created at startup, but will be when one of the
                             -- client in the "class" section will start. It will be created on
                             -- the client startup screen
        exclusive   = true,
        layout      = awful.layout.suit.max,
        class       = {
            "Assistant"     , "Okular"         , "Evince"    , "EPDFviewer"   , "xpdf",
            "Xpdf"          ,                                        }
    } ,
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
    "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"               ,
    "feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color"    ,
    "kcolorchooser" , "plasmoidviewer" , "Xephyr"    , "kruler"       , "plasmaengineexplorer",
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
    "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" 
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
    "Xephyr"       , "ksnapshot"       , "kruler"
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
    "kcalc"
}

tyrannical.settings.block_children_focus_stealing = true --Block popups ()
tyrannical.settings.group_children = true --Force popups/dialogs to have the same tags as the parent client

```

Then edit this section to fit your needs. 

##### The available tag properties are:

| Property                  | Description                                          | Type             |
| ------------------------- | ---------------------------------------------------- |:----------------:|
| **class**                 | Match these classes to this tag                      | array of string  |
| **instance**              | Match these instances to this tag. ★                 | array of string  |
| **exclusive**             | Allow only client from the "class" attributes        | boolean          |
| **exec_once**             | Execute when the tag is first selected               | string (command) |
| **force_screen**          | Force a screen                                       | boolean          |
| **hide**                  | Hide this tag from view                              | boolean          |
| **icon**                  | Tag icon                                             | path             |
| **init**                  | Create when awesome launch                           | boolean          |
| **layout**                | The tag layout                                       | layout           |
| **mwfact**                | Tiled layout master/slave ratio                      | float(0-1)       |
| **ncol**                  | Number of columns                                    | number           |
| **nmaster**               | Number of master clients                             | number           |
| **no_focus_stealing_in**  | Do not select this tag when a new client is added    | boolean          |
| **no_focus_stealing_out** | Do not unselect when a new client is added elsewhere | boolean          |
| **screen**                | Tag screen(s)                                        | number or array  |
| **selected**              | Select when created                                  | boolean          |
| **volatile**              | Destroy when the last client is closed               | boolean          |
| **fallback**              | Use this tag for unmatched clients                   | boolean          |
| **locked**                | Do not add any more clients to this tag              | boolean          |
| **max_clients**           | Maximum number of clients before creating a new tag  | number or func   |
| **onetimer**              | Once deleted, this tag cannot be created again       | boolean          |

★Takes precedence over class

##### The available client properties are:

| Property                  | Description                                    | Type             |
| ------------------------- | ---------------------------------------------- |:----------------:|
| **above**                 | Display above other clients                    | boolean          |
| **below**                 | Display below other clients                    | boolean          |
| **border_color**          | Change client default border color*            | string           |
| **border_width**          | Change the client border width                 | number           |
| **centered**              | Center the client on the screen at launch      | boolean          |
| **floating**              | Make the client floating or insert into layout | boolean          |
| **focusable**             | Allow focus                                    | boolean          |
| **fullscreen**            | Cover the whole screen                         | boolean          |
| **hidden**                | Hide this client (minimize)                    | boolean          |
| **intrusive**             | Ignore tag "exclusive" property                | boolean          |
| **maximized_horizontal**  | Cover all horizontal space                     | boolean          |
| **maximized_vertical**    | Cover all vertical space                       | boolean          |
| **ontop**                 | Display on top of the normal layout layer      | boolean          |
| **skip_taskbar**          | Do not add to tasklist                         | boolean          |
| **sticky**                | Display in all tags                            | boolean          |
| **master**                | Open a client as master (bigger)               | boolean          |
| **slave**                 | Open a client as slave (smaller)               | boolean          |
| **no_autofocus**          | Do not focus a new instance                    | boolean          |
| **tag**                   | Asign to a pre-existing tag object             | tag/func/array   |
| **new_tag**               | Do not focus a new instance                    | boolean or array |
| **callback**              | A function returning an array or properties    | function         |

 *Need default rc.lua modifications in the "client.connect_signal('focus')" section

##### The available global settings are:

| Property                               | Description                                         | Type             |
| -------------------------------------- | --------------------------------------------------- |:----------------:|
| **block_children_focus_stealing**      | Prevent popups from stealing focus                  | boolean          |
| **default_layout**                     | The default layout for tags                         | layout           |
| **group_children**                     | Add dialogs to the same tags as their parent client | boolean          |
| **mwfact**                             | The default master/slave ratio                      | float (0-1)      |
| **force_odd_as_intrusive**             | Make all non-normal (dock, splash) intrusive        | boolean          |
| **no_focus_stealing_out**              | Do not unselect tags when a new client is added     | boolean          |


It's worth noting that some settings like `mwfact` and `default_layout` should
be set **before** the tag arrow. Otherwise they wont take effect at startup.

-----------------------------------------------------

### FAQ

 * [Is it possible to add, remove and move tags?](https://github.com/Elv13/tyrannical#is-it-possible-to-add-remove-and-move-tags)
 * [How do I get a client class?](https://github.com/Elv13/tyrannical#how-do-i-get-a-client-class)
 * [Is it possible to have relative indexes (position) for tags?](https://github.com/Elv13/tyrannical#is-it-possible-to-have-relative-indexes-position-for-tags)
 * [Is it possible to change the layout when adding a new client?](https://github.com/Elv13/tyrannical#is-it-possible-to-change-the-layout-when-adding-a-new-client)
 * [Is it possible to directly launch clients in the current tag or a new one?](https://github.com/Elv13/tyrannical#is-it-possible-to-directly-launch-clients-in-the-current-tag-or-a-new-one)
 * [Can I alter the client properties based on runtime criterias?](https://github.com/Elv13/tyrannical#can-i-alter-the-client-properties-based-on-runtime-criterias)
 * [Is it possible to match clients based on properties other than class or instance?](https://github.com/Elv13/tyrannical#is-it-possible-to-match-clients-based-on-properties-other-than-class-or-instance)

#### Is it possible to add, remove and move tags?

Yes, this feature is now part of awful. It does not require an external module
anymore. Awful's dynamic tag implementation is compatible with Tyrannical. See
the [API](http://awesome.naquadah.org/doc/api/) and this
[user contribution](https://github.com/Elv13/tyrannical/issues/15#issuecomment-18227575)

#### How do I get a client class?

From a terminal, execute `xprop`, then click on an instance of that client.
There will be a "CLASS" line with one or more class. Always pick the second one,
Tyrannical is not case sensitive.

#### Is it possible to have relative indexes (position) for tags?

Tyrannical shares awful's tag list. It does not keep its own indexes since this
would make it harder to implement this feature in the core. Given that, this
feature is outside the project scope. That being said, nothing prevents you
from adding a "position" property to the tag. Once this is done, edit the
default ```rc.lua``` keybindings to find the position by looping the tags. In
case the tag is not yet created, you can access it with
```tyrannical.tags_by_name["your tag name"]``` array. This array is
automatically generated. You can then add it using
```awful.tag.add(tyrannical.tags_by_name["your tag
name"].name,tyrannical.tags_by_name["your tag name"])```. Tyrannical's purpose
is not to duplicate or change ```awful.tag``` behavior, it is simply a
configuration wrapper.

#### Is it possible to change the layout when adding a new client?

Yes and no. There is a workaround using a `max_clients` callback. This function
has to return a number of clients for a given tag, but can also be used to alter
them. The function take a client as first parameter and a possible tag as the
second. Returning `0` will always force a new tag to be created. Returning nil
will allow the client into that tag. This function switch between `tile` and
`magnifier`:

```lua
    local function aero_or_magnifier(c,tag)
        local count = #match:clients() + 1 --The client is not there yet
        if count == 2 then
            awful.layout.set(awful.layout.suit.tile,tag)
            awful.tag.setproperty(tag,"mwfact",0.5)
        else
            awful.layout.set(awful.layout.suit.magnifier,tag)
        end
        return 5 -- Use a maximum of 5 clients
    end
```

#### Is it possible to directly launch clients in the current tag or a new one?

This feature is mostly available for Awesome 3.5.3+, 3.5.6+ is recommanded.
Tyrannical will use the "startup notification" field in clients that support it
to track a spawn request. Some applications, such as GVim and XTerm, doesn't
support this. URxvt, Konsole and Gnome terminal does.

Here are some example:

```lua
    -- Spawn in a new tag
    awful.util.spawn("urxvt",{new_tag=true})
    
    -- Or for more advanced use case, you can use a full tag definition too
    awful.util.spawn("urxvt",{ new_tag= {
       name = "MyNewTag",
       exclusive = true,
    })
    
    -- Spawn in the current tag, floating and on top
    awful.util.spawn(terminal,{intrusive=true, floating=true, ontop=true})
    
    -- Spawn in an existing tag (assume `my_tag` exist)
    -- Note that `tag` can also be an array of tags or a function returning
    -- an array of tags
    awful.util.spawn(terminal,{tag=my_tag})
```

For Awesome 3.5.6+, it is possible to replace the default mod4+r keybinding with
a more powerful one:

```lua
    awful.key({ modkey }, "r",
        function ()
            awful.prompt.run({ prompt = "Run: ", hooks = {
                {{         },"Return",function(command)
                    local result = awful.util.spawn(command)
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end},
                {{"Mod1"   },"Return",function(command)
                    local result = awful.util.spawn(command,{intrusive=true})
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end},
                {{"Shift"  },"Return",function(command)
                    local result = awful.util.spawn(command,{intrusive=true,ontop=true,floating=true})
                    mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                    return true
                end}
            }},
            mypromptbox[mouse.screen].widget,nil,
            awful.completion.shell,
            awful.util.getdir("cache") .. "/history")
        end),
```

When using this, instead of pressing `Return` to spawn the application, you can
use `Alt+Return` to launch it as an `intrusive` client. You can add more sections
to support more use case (such as `Shift+Return` to launch as `floating` as shown
above)

#### Can I alter the client properties based on runtime criterias?

Yes, everytime Tyrannical consider a client, it will call the `callback` function.
This function can return an array or properties that will have precedence over
any properties set by rules. The only limitation of this system is that the
callback function need to be synchronious. So long bash commands will cause
Awesome to block until the result is parsed.

#### Is it possible to match clients based on properties other than class or instance?

Yes, but not directly. You need to create a new `awful.rule` that overrides the class property and then match that to your tag:

```lua
awful.rules.rules = {
    --default stuff here,
    {
        rule = { class = "URxvt", name = "dev"  },
        callback = function(c)
        awful.client.property.set(c, "overwrite_class", "urxvt:dev")
        end
    }
}
```
This example changes the class of URxvt with name "dev" from "urxvt" to "urxvt:dev" which then can be matched to a tag.

For more information on possible porperties look at [Awful Rules](http://awesome.naquadah.org/wiki/Understanding_Rules) or [API](http://awesome.naquadah.org/doc/api/modules/client.html)

#### What is Tyrannical license?

Tyrannical is licensed under the [2 clause BSD](http://opensource.org/licenses/BSD-2-Clause)
