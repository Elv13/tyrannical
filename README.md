Tyrannical—A simple tag managment engine for Awesome
-----------------------------------------------------

### News

#### January 2019

Tyrannical 2.0.0 has been released. It is the first and last official release
for Awesome 4.0 to 4.2. The new `no_tag_deselect` option has been added (
thanks to @cherti).

From now on, only AwesomeWM 4.3+ is supported. Parts of Tyrannical were merged
into AwesomeWM 4.3 and it will make everything more reliable.

#### April 2016

Tyrannical 1.0.0 has been released. This is the first and last version for
Awesome 3.5. Tyrannical is still in active developement and a brand new
implementation will be released shortly after Awesome 4.0 is released.

Tyrannical goal is and has always been to avoid re-inventing the wheel and
use existing Awesome APIs to manage tags. This will now get much easier with
Awesome 4.0 and a new "request" API designed with Tyrannical like workflows
in mind. This will avoid turning the code into a unreadable ball of spagetti
as the current implementation became.

#### December 2016

The master branch **is for Awesome 4.4+**. If you use **Awesome 3.5,**
**use the 1.0.0 version**. If you use Awesome 4.0-2.4, use the 2.0.0 version.

### Description

Tyrannical is a tag management system for Awesome 3.5+. It is inspired and
intend to replace the Shifty module popular in older versions of Awesome.

Compared to Shifty, Tyrannical doesn't try to replace `awful.tag` and
`awful.rules`, but rather extend them to support the following features:

 * Declarative tags declaration description
 * Rules based around the tags rather than the clients
 * Rules based around the client properties rather than the clients
 * A dynamic tag workflow where tags are created and removed on demand
 * A stateful tag model
 * More powerful focus stealing rules

Tyrannical was created because:

 * Shifty code is too complex and outdated to be maintained
 * `awful` support dynamic tagging, but it's awkward to use
 * It implements a workflow that better fit my taste than the default one

Tyrannical 1.0 versus 2.0-alpha:

While I am among the first AwesomeWM user, I only became a major contributor
during the 4.0 development cycle. The new version of Awesome has new APIs
designed to improve alternate workflows such as the one proposed by Tyrannical.

The new version aims to rewrite Tyrannical to use these APIs instead of the
hacks that allowed the original version to work. The original code also became
unmaintainable due to horrible coding practices and repeated hacks to fine tune
its behavior.

Finally, Awesome 4.0 introduces support for adding and removing screen at
runtime. Therefor, being able to expand and contract the tag set dynamically
is finally possible. Being able to support the use case where a laptop is
optionally plugged to an external monitor will be implemented once feature
parity has been achieved.

Future:

My first attempt at implementing dynamic layouts failed back in 2012, but for a
year I have been using a new implementation. This isn't expected to land in
Awesome anytime soon. But once it does, Tyrannical will gain the ability to
describe whole dynamic layouts instead of "just" its tag.

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

**no_tag_deselect:**
When a new client is added somewhere, that tag gets selected in addition to the
current selection of tags instead of being selected solely.

**no_autofocus:**
When a class has this flag, then new clients wont be focused when they are
launched. This is useful for download managers or background terminals tasks.

### Installation

This is how to install Tyrannical for Awesome 4.X:

```
mkdir -p ~/.config/awesome
cd ~/.config/awesome
git clone https://github.com/Elv13/tyrannical.git
```

Awesome 3.5 users should fetch the version 1.0.0.

Then either use the sample rc.lua or upgrade your existing one.

### Configuration

If you previously used Shifty, you will feel comfortable using Tyrannical. The
only difference is that in Tyrannical class matching is integrated into the tag
configuration section. More advanced rules can be created using
```awful.rules```. Again, Tyrannical was not created to duplicate awful, but to
make dynamic (and static, as a side effect) tagging configuration easier. This
module doesn't require any major initialisation. Compared to shifty, it is much
more transparent.

The first modification is to include the module at the top of your `rc.lua`
(after `awful.rules = require("awful.rules")`):

```lua
local tyrannical = require("tyrannical")
--require("tyrannical.shortcut") --optional
```

Then this line has to be removed:

```lua
awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
```

And this added **outside** of the `awful.screen.connect_for_each_screen` section:

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
        name        = "Files",
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
        name        = "Develop",
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
tyrannical.properties.placement = {
    kcalc = awful.placement.centered
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
| **master_width_factor**   | Tiled layout master/slave ratio                      | float(0-1)       |
| **column_count**          | Number of columns                                    | number           |
| **master_count**          | Number of master clients                             | number           |
| **no_focus_stealing_in**  | Do not select this tag when a new client is added    | boolean          |
| **no_focus_stealing_out** | Do not unselect when a new client is added elsewhere | boolean          |
| **no_tag_deselect**       | Do not unselect other tags spawning/selecting this   | boolean          |
| **screen**                | Tag screen(s)                                        | number or array  |
| **selected**              | Select when created                                  | boolean          |
| **volatile**              | Destroy when the last client is closed               | boolean          |
| **fallback**              | Use this tag for unmatched clients                   | boolean          |
| **locked**                | Do not add any more clients to this tag              | boolean          |
| **max_clients**           | Maximum number of clients before creating a new tag  | number or func   |
| **onetimer**              | Once deleted, this tag cannot be created again       | boolean          |

★Takes precedence over class

See: http://new.awesomewm.org/apidoc/classes/tag.html

##### The available client properties are:

Note that every property can also be a function. In that case it has a client
as the first parameter and the property array as the second. It must return a
value with a compatible type. Those properties are directly converted into
`awful.rules`.

| Property                  | Description                                    | Type             |
| ------------------------- | ---------------------------------------------- |:----------------:|
| **above**                 | Display above other clients                    | boolean          |
| **below**                 | Display below other clients                    | boolean          |
| **border_color**          | Change client default border color*            | string           |
| **border_width**          | Change the client border width                 | number           |
| **placement**             | Center the client on the screen at launch      | awful.placement  |
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
| **tag**                   | Asign to a pre-existing tag object             | tag/array/string |
| **tags**                  | Asign to a pre-existing tag object             | array            |
| **new_tag**               | Do not focus a new instance                    | boolean or array |
| **callback**              | A function returning an array or properties    | function         |

 *Need default rc.lua modifications in the "client.connect_signal('focus')" section

See:

 * http://new.awesomewm.org/apidoc/classes/client.html
 * http://new.awesomewm.org/apidoc/libraries/awful.rules.html

##### The available global settings are:

| Property                               | Description                                         | Type             |
| -------------------------------------- | --------------------------------------------------- |:----------------:|
| **block_children_focus_stealing**      | Prevent popups from stealing focus                  | boolean          |
| **default_layout**                     | The default layout for tags                         | layout           |
| **group_children**                     | Add dialogs to the same tags as their parent client | boolean          |
| **master_width_factor**                | The default master/slave ratio                      | float (0-1)      |
| **force_odd_as_intrusive**             | Make all non-normal (dock, splash) intrusive        | boolean          |
| **no_focus_stealing_out**              | Do not unselect tags when a new client is added     | boolean          |
| **favor_focused**                      | Prefer the focused screen to the screen property    | boolean          |


It's worth noting that some settings like `master_width_factor` and `default_layout` should
be set **before** the tag arrow. Otherwise they wont take effect at startup.

**favor_focused** Is enabled by default for tags created after startup for
convinience. Use *force_screen* or `tyrannical.settings.favor_focused = false`
to do otherwise.

-----------------------------------------------------

### FAQ

 * [Is Tyrannical under active development](https://github.com/Elv13/tyrannical#is-tyrannical-under-active-development)
 * [Is it possible to add, remove and move tags?](https://github.com/Elv13/tyrannical#is-it-possible-to-add-remove-and-move-tags)
 * [How do I get a client class?](https://github.com/Elv13/tyrannical#how-do-i-get-a-client-class)
 * [Is it possible to have relative indexes (position) for tags?](https://github.com/Elv13/tyrannical#is-it-possible-to-have-relative-indexes-position-for-tags)
 * [Is it possible to change the layout when adding a new client?](https://github.com/Elv13/tyrannical#is-it-possible-to-change-the-layout-when-adding-a-new-client)
 * [Is it possible to directly launch clients in the current tag or a new one?](https://github.com/Elv13/tyrannical#is-it-possible-to-directly-launch-clients-in-the-current-tag-or-a-new-one)
 * [Can I alter the client properties based on runtime criterias?](https://github.com/Elv13/tyrannical#can-i-alter-the-client-properties-based-on-runtime-criterias)
 * [Is it possible to match clients based on properties other than class or instance?](https://github.com/Elv13/tyrannical#is-it-possible-to-match-clients-based-on-properties-other-than-class-or-instance)

#### Is Tyrannical under active development

Yes.

Note that the Tyrannical feature set is complete and the scope isn't likely to
be expanded. The new features, if any, are intended to refining the current
algorithm. Parts by part, Tyrannical features are upstreamed into Awesome itself
and it is where the main development is happening.

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
default `rc.lua` keybindings to find the position by looping the tags. In
case the tag is not yet created, you can access it with
`tyrannical.tags_by_name["your tag name"]` array. This array is
automatically generated. You can then add it using
`awful.tag.add(tyrannical.tags_by_name["your tag
name"].name,tyrannical.tags_by_name["your tag name"])`. Tyrannical's purpose
is not to duplicate or change `awful.tag` behavior, it is simply a
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
        tag.layout = awful.layout.suit.tile
        tag.master_width_factor = 0.5
    else
        tag.layout = awful.layout.suit.magnifier
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
awful.spawn("urxvt",{new_tag=true})

-- Or for more advanced use case, you can use a full tag definition too
awful.spawn("urxvt",{ new_tag= {
   name = "MyNewTag",
   exclusive = true,
})

-- Spawn in the current tag, floating and on top
awful.spawn(terminal,{intrusive=true, floating=true, ontop=true})

-- Spawn in an existing tag (assume `my_tag` exist)
-- Note that `tag` can also be an array of tags or a function returning
-- an array of tags
awful.spawn(terminal,{tag=my_tag})
```

For Awesome 3.5.6+, it is possible to replace the default mod4+r keybinding with
a more powerful one:

```lua
awful.key({ modkey }, "r",
    function ()
        awful.prompt.run({ prompt = "Run: ", hooks = {
            {{         },"Return",function(command)
                local result = awful.spawn(command)
                mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                return true
            end},
            {{"Mod1"   },"Return",function(command)
                local result = awful.spawn(command,{intrusive=true})
                mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
                return true
            end},
            {{"Shift"  },"Return",function(command)
                local result = awful.spawn(command,{intrusive=true,ontop=true,floating=true})
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
        c.overwrite_class = "urxvt:dev"
    end
}
}
```
This example changes the class of URxvt with name "dev" from "urxvt" to "urxvt:dev" which then can be matched to a tag.

For more information on possible properties look at [Awful Rules](http://awesome.naquadah.org/wiki/Understanding_Rules) or [API](http://awesome.naquadah.org/doc/api/modules/client.html)

#### What is Tyrannical license?

Tyrannical is licensed under the [2 clause BSD](http://opensource.org/licenses/BSD-2-Clause)
