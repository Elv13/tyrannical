-- Coment this out if you dont need to test it this way
-- Remove last dir
local pwd = os.getenv("PWD"):match("(.+)/.-")
package.path = pwd .. "/?.lua;" .. pwd .. "/?/init.lua;" .. package.path
local tyranical = require("awesome-tyranical")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}


tyranical.tags = {
    {
        name = "Term",
        init        = true                                           ,
        exclusive   = true                                           ,
--        icon        = utils.tools.invertedIconPath("term.png")       ,
        screen      = 1,-- {config.data().scr.pri, config.data().scr.sec} ,
        layout      = awful.layout.suit.tile                         ,
        class       = {
            "xterm" , "urxvt" , "aterm","URxvt","XTerm"
        },
        match       = {
            "konsole"
        }
    } ,
    {
        name = "Internet",
        init        = true                                           ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("net.png")        ,
        screen      = 1,--config.data().scr.pri                          ,
        layout      = awful.layout.suit.max                          ,
        class = {
            "Opera"         , "Firefox"        , "Rekonq"    , "Dillo"        , "Arora",
            "Chromium"      , "nightly"        , "Nightly"   , "minefield"    , "Minefield" }
    } ,
    {
        name = "Files",
        init        = true                                           ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("folder.png")     ,
        screen      = 1,--config.data().scr.pri                          ,
        layout      = awful.layout.suit.tile                         ,
        class  = { 
            "Thunar"        , "Konqueror"      , "Dolphin"   , "ark"          , "Nautilus",         }
    } ,
    {
        name = "Develop",
     init        = true                                              ,
        exclusive   = true                                           ,
--                     screen      = 1,--{config.data().scr.pri, config.data().scr.sec}     ,
     --   icon        = utils.tools.invertedIconPath("bug.png")        ,
        layout      = awful.layout.suit.max                          ,
        class ={ 
            "Kate"          , "KDevelop"       , "Codeblocks", "Code::Blocks" , "DDD", "kate4"             }
    } ,
    {
        name = "Edit",
        init        = true                                           ,
        exclusive   = true                                           ,
--                     screen      =1,-- {config.data().scr.pri, config.data().scr.sec}     ,
     --   icon        = utils.tools.invertedIconPath("editor.png")     ,
        layout      = awful.layout.suit.tile.bottom                  ,
        class = { 
            "KWrite"        , "GVim"           , "Emacs"     , "Code::Blocks" , "DDD"               }
    } ,
    {
        name = "Media",
        init        = true                                           ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("media.png")      ,
        layout      = awful.layout.suit.max                          ,
        class = { 
            "Xine"          , "xine Panel"     , "xine*"     , "MPlayer"      , "GMPlayer",
            "XMMS" }
    } ,
    {
        name = "Doc",
    --  init        = true                                           ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("info.png")       ,
--                     screen      = config.data().scr.music                          ,
        layout      = awful.layout.suit.max                          ,
        class       = {
            "Assistant"     , "Okular"         , "Evince"    , "EPDFviewer"   , "xpdf",
            "Xpdf"          ,                                        }
    } ,


    -----------------VOLATILE TAGS-----------------------
    {
        name        = "Imaging",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("image.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Inkscape"      , "KolourPaint"    , "Krita"     , "Karbon"       , "Karbon14"}
    } ,
    {
        name        = "Picture",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("image.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Digikam"       , "F-Spot"         , "GPicView"  , "ShowPhoto"    , "KPhotoAlbum"}
    } ,
    {
        name        = "Video",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("video.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"KDenLive"      , "Cinelerra"      , "AVIDeMux"  , "Kino"}
    } ,
    {
        name        = "Movie",
        init        = false                                          ,
        position    = 12                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("video.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"VLC"}
    } ,
    {
        name        = "3D",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("3d.png")         ,
        layout      = awful.layout.suit.max.fullscreen               ,
        class       = {"Blender"       , "Maya"           , "K-3D"      , "KPovModeler"  , }
    } ,
    {
        name        = "Music",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = 1,----config.data().scr.music or config.data().scr.pri   ,
     --   icon        = utils.tools.invertedIconPath("media.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Amarok"        , "SongBird"       , "last.fm"   ,}
    } ,
    {
        name        = "Down",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("download.png")   ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Transmission"  , "KGet"}
    } ,
    {
        name        = "Office",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("office.png")     ,
        layout      = awful.layout.suit.max                          ,
        class       = {
            "OOWriter"      , "OOCalc"         , "OOMath"    , "OOImpress"    , "OOBase"       ,
            "SQLitebrowser" , "Silverun"       , "Workbench" , "KWord"        , "KSpread"      ,
            "KPres","Basket", "openoffice.org" , "OpenOffice.*"               ,                }
    } ,
    {
        name        = "RSS",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("rss.png")        ,
        layout      = awful.layout.suit.max                          ,
        class       = {}
    } ,
    {
        name        = "Chat",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = 1,--config.data().scr.sec or config.data().scr.sec ,
     --   icon        = utils.tools.invertedIconPath("chat.png")       ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"Pidgin"        , "Kopete"         ,}
    } ,
    {
        name        = "Burning",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
     --   icon        = utils.tools.invertedIconPath("burn.png")       ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"k3b"}
    } ,
    {
        name        = "Mail",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
--         screen      = 1,--config.data().scr.sec or config.data().scr.pri     ,
     --   icon        = utils.tools.invertedIconPath("mail2.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Thunderbird"   , "kmail"          , "evolution" ,}
    } ,
    {
        name        = "IRC",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = 1,--config.data().scr.irc or config.data().scr.pri     ,
        init        = true                                           ,
        spawn       = "konversation"                                 ,
     --   icon        = utils.tools.invertedIconPath("irc.png")        ,
        force_screen= true                                           ,
        layout      = awful.layout.suit.fair                         ,
        class       = {"Konversation"  , "Botch"          , "WeeChat"   , "weechat"      , "irssi"}
    } ,
    {
        name        = "Test",
        init        = false                                          ,
        position    = 99                                             ,
        exclusive   = false                                          ,
        screen      = 1,--config.data().scr.sec or config.data().scr.pri     ,
        leave_kills = true                                           ,
        persist     = true                                           ,
     --   icon        = utils.tools.invertedIconPath("tools.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {}
    } ,
    {
        name        = "Config",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
     --   icon        = utils.tools.invertedIconPath("tools.png")      ,
        layout      = awful.layout.suit.max                        ,
        class       = {"Systemsettings", "Kcontrol"       , "gconf-editor"}
    } ,
    {
        name        = "Game",
        init        = false                                          ,
        screen      = 1,--config.data().scr.pri                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
     --   icon        = utils.tools.invertedIconPath("game.png")       ,
        force_screen= true                                           ,
        layout      = awful.layout.suit.max                        ,
        class       = {"sauer_client"  , "Cube 2$"        , "Cube 2: Sauerbraten"        ,}
    } ,
    {
        name        = "Gimp",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
     --   icon        = utils.tools.invertedIconPath("image.png")      ,
        layout      = awful.layout.tile                              ,
        nmaster     = 1                                              ,
        incncol     = 10                                             ,
        ncol        = 2                                              ,
        mwfact      = 0.00                                           ,
        class       = {}
    } ,
    {
        name        = "Other",
        init        = true                                           ,
        position    = 15                                             ,
        exclusive   = false                                          ,
     --   icon        = utils.tools.invertedIconPath("term.png")       ,
        max_clients = 5                                              ,
        screen      = {3, 4, 5}                                      ,
        layout      = awful.layout.suit.tile                         ,
        class       = {}
    } ,
    {
        name        = "MediaCenter",
        init        = true                                           ,
        position    = 15                                             ,
        exclusive   = false                                          ,
     --   icon        = utils.tools.invertedIconPath("video.png")      ,
        max_clients = 5                                              ,
        screen      = 1,--config.data().scr.media or config.data().scr.pri   ,
        init        = "mythfrontend"                                 ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"mythfrontend"  , "xbmc"           ,}
    } ,
    }
tyranical.properties.intrusive = {
    "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"           ,
    "feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color",
    "kcolorchooser" , "plasmoidviewer" , "plasmaengineexplorer" , "Xephyr" , "kruler"     ,
}
tyranical.properties.floating = {
    "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" 
}

tyranical.properties.ontop = {
    "Xephyr"       , "ksnapshot"       , "kruler"
}

tyranical.properties.size_hints_honor = { xterm = false, URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false}


-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                       awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   -- keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        --if tags[screen][i] then
                         --   awful.tag.viewonly(tags[screen][i])
                        --end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      -- if tags[screen][i] then
                        --  awful.tag.viewtoggle(tags[screen][i])
                      --end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      -- if client.focus and tags[client.focus.screen][i] then
                          --awful.client.movetotag(tags[client.focus.screen][i])
                  --    end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      -- if client.focus and tags[client.focus.screen][i] then
                          --awful.client.toggletag(tags[client.focus.screen][i])
                      --end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
