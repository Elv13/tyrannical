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
        clone_on    = 2, -- Create a single instance of this tag on screen 1, but also show it on screen 2
                         -- The tag can be used on both screen, but only one at once
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

##### That available tags properties are:

| Property                  | Description                                          | Type             |
| ------------------------- | ---------------------------------------------------- |:----------------:|
| **class**                 | Match these classes to this tag                      | array of string  |
| **clone_on**              | Create a clone on screen(s)                          | number or array  |
| **exclusive**             | Allow only client from the "class" attributes        | boolean          |
| **exec_once**             | Execute when the tag is first selected               | string (command) |
| **force_screen**          | Force a screen                                       | number           |
| **hide**                  | Hide this tag from view                              | boolean          |
| **icon**                  | Tag icon                                             | path             |
| **init**                  | Create when awesome launch                           | boolean          |
| **layout**                | The tag layout                                       | layout           |
| **mwfact**                | Tiled layout master/slave ratio                      | float(0-1)       |
| **ncol**                  | Number of columns                                    | number           |
| **nmaster**               | Number of master clients                             | number           |
| **no_focus_stealing**     | Do not change focus then a new client is added       | boolean          |
| **no_focus_stealing_in**  | Do not select this tag when a new client is added    | boolean          |
| **no_focus_stealing_out** | Do not unselect when a new client is added elsewhere | boolean          |
| **screen**                | Tag screen(s)                                        | number or array  |
| **selected**              | Select when created                                  | boolean          |
| **volatile**              | Destroy when the last client is closed               | boolean          |


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

 *Need default rc.lua modifications in the "client.connect_signal('focus')" section

##### The available global settings are:

| Property                          | Description                                         | Type             |
| --------------------------------- | --------------------------------------------------- |:----------------:|
| **block_children_focus_stealing** | Prevent popups from stealing focus                  | boolean          |
| **default_layout**                | The default layout for tags                         | layout           |
| **group_children**                | Add dialogs to the same tags as their parent client | boolean          |
| **mwfact**                        | The default master/slave ratio                      | float (0-1)      |
| **force_odd_as_intrusive**        | Make all non-normal (dock, splash) intrusive        | boolean          |
| **no_focus_stealing_out**         | Do not unselect tags when a new client is added     | boolean          |


It's worth noting that some settings like `mwfact` and `default_layout` should
be set **before** the tag arrow. Otherwise they wont take effect at startup.

-----------------------------------------------------

### FAQ

#### Is it possible to add, remove and move tags?

Yes, this feature is now part of awful. It does not require an external module
anymore. Awful's dynamic tag implementation is compatible with Tyrannical. See
the [API](http://awesome.naquadah.org/doc/api/) and this
[user contribution](https://github.com/Elv13/tyrannical/issues/15#issuecomment-18227575)

#### How do I get a client class?

From a terminal, execute `xprop`, then click on an instance of that client.
There will be a "CLASS" line with one or more class. Always pick the first one,
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

#### What is Tyrannical license?

Tyrannical is licensed under the [2 clause BSD](http://opensource.org/licenses/BSD-2-Clause)
