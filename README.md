Tyrannical—A simple tag matching engine for Awesome
-----------------------------------------------------

### Description
Shifty was great and served us well since the early days of the Awesome 3.\*
series, but just as many aged kid TV stars, it has not grown that well. Many of
its once unique features are now supported by the default ```awful.tag```
engine, adding legacy complexity to the code base and affecting performance.

This is why Tyrannical was created. It is a light rule engine offering pretty
much the same rule configuration, but without all the dynamic tag code. Note
that dynamic tagging is now supported directly by awesome.

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

The first modification is to include the module at the top of your ```rc.lua```:
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
```

Then edit this section to fit your needs. That available tag properties are:
*   mwfact
*   nmaster
*   ncol
*   icon
*   hide
*   screen (number or array)
*   exclusive
*   layout
*   init
*   clone_on
*   class
*   exec_once
*   selected

The available client properties are:
*   floating
*   intrusive
*   ontop
*   border_color
*   border_width
*   centered
*   hidden
*   below
*   above
*   fullscreen
*   maximized_horizontal
*   maximized_vertical
*   sticky
*   focusable
*   skip_taskbar

### FAQ

#### Is it possible to add, remove and move tags?

Yes, this feature is now part of awful. It does not require an external module
anymore. Awful's dynamic tag implementation is compatible with Tyrannical. See
the [API](http://awesome.naquadah.org/doc/api/).

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
