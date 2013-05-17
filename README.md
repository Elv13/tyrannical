Tyrannical - A simple rule engine
------------------------------

### Description
Shifty was great and served us well since the early days of the Awesome 3.\* series, but just as
many kid aged TV stars, it havn't grown that well. Many of it's, once unique, features are now
supported by the default awful.tag engine, adding legacy complexity to the code base and affecting
performance.

This is why Tyrannical was created. It is a light rule engine offering pretty much the same rules configuration,
but without all the dynamic tag code. Note that dynamic tagging is now supported directly by awesome.

### Examples

Install [Xephyr](http://www.freedesktop.org/wiki/Software/Xephyr) and run the following script

 sh utils/xephyr.sh start

*Note:* The tyranical repository must be named awesome-tyranical for the script to work out of the box.

Also see samples.rc.lua for a sample.

### Configuration

If you once used Shifty, you will feel confortable with Tyrannical. The only different is that
Tyrannical integrate class matching directly in the tag configuration section. More advanced
rules can be created using awful.rules. Again, Tyrannical was not created to duplicate awful,
but to make dynamic (and static, as a side effect) tagging configuration easier. This module
doesn't require any major initialisation, compared to shifty, it is much more transparent.

The first modification is to include the module at the top of rc.lua:
<pre>local tyrannical = require("tyrannical")</pre>

Then this section have to be replaced:
<pre>-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}</pre>

by:

<pre>tyrannical.tags = {
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
tyranic.properties.centered = {
    "kcalc"
}</pre>

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

