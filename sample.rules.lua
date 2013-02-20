local awful = require("awful")


-- }}}

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

tags = {} --TODO remove

tyranic.tags = {
    {
        name = "Term",
        init        = true                                           ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("term.png")       ,
        screen      = {config.data().scr.pri, config.data().scr.sec} ,
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
        icon        = utils.tools.invertedIconPath("net.png")        ,
        screen      = config.data().scr.pri                          ,
        layout      = awful.layout.suit.max                          ,
        class = {
            "Opera"         , "Firefox"        , "Rekonq"    , "Dillo"        , "Arora",
            "Chromium"      , "nightly"        , "Nightly"   , "minefield"    , "Minefield" }
    } ,
    {
        name = "Files",
        init        = true                                           ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("folder.png")     ,
        screen      = config.data().scr.pri                          ,
        layout      = awful.layout.suit.tile                         ,
        class  = { 
            "Thunar"        , "Konqueror"      , "Dolphin"   , "ark"          , "Nautilus",         }
    } ,
    {
        name = "Develop",
     init        = true                                              ,
        exclusive   = true                                           ,
--                     screen      = {config.data().scr.pri, config.data().scr.sec}     ,
        icon        = utils.tools.invertedIconPath("bug.png")        ,
        layout      = awful.layout.suit.max                          ,
        class ={ 
            "Kate"          , "KDevelop"       , "Codeblocks", "Code::Blocks" , "DDD", "kate4"             }
    } ,
    {
        name = "Edit",
        init        = true                                           ,
        exclusive   = true                                           ,
--                     screen      = {config.data().scr.pri, config.data().scr.sec}     ,
        icon        = utils.tools.invertedIconPath("editor.png")     ,
        layout      = awful.layout.suit.tile.bottom                  ,
        class = { 
            "KWrite"        , "GVim"           , "Emacs"     , "Code::Blocks" , "DDD"               }
    } ,
    {
        name = "Media",
        init        = true                                           ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("media.png")      ,
        layout      = awful.layout.suit.max                          ,
        class = { 
            "Xine"          , "xine Panel"     , "xine*"     , "MPlayer"      , "GMPlayer",
            "XMMS" }
    } ,
    {
        name = "Doc",
    --  init        = true                                           ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("info.png")       ,
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
        icon        = utils.tools.invertedIconPath("image.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Inkscape"      , "KolourPaint"    , "Krita"     , "Karbon"       , "Karbon14"}
    } ,
    {
        name        = "Picture",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("image.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Digikam"       , "F-Spot"         , "GPicView"  , "ShowPhoto"    , "KPhotoAlbum"}
    } ,
    {
        name        = "Video",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("video.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"KDenLive"      , "Cinelerra"      , "AVIDeMux"  , "Kino"}
    } ,
    {
        name        = "Movie",
        init        = false                                          ,
        position    = 12                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("video.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"VLC"}
    } ,
    {
        name        = "3D",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("3d.png")         ,
        layout      = awful.layout.suit.max.fullscreen               ,
        class       = {"Blender"       , "Maya"           , "K-3D"      , "KPovModeler"  , }
    } ,
    {
        name        = "Music",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = config.data().scr.music or config.data().scr.pri   ,
        icon        = utils.tools.invertedIconPath("media.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Amarok"        , "SongBird"       , "last.fm"   ,}
    } ,
    {
        name        = "Down",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("download.png")   ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Transmission"  , "KGet"}
    } ,
    {
        name        = "Office",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("office.png")     ,
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
        icon        = utils.tools.invertedIconPath("rss.png")        ,
        layout      = awful.layout.suit.max                          ,
        class       = {}
    } ,
    {
        name        = "Chat",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = config.data().scr.sec or config.data().scr.sec ,
        icon        = utils.tools.invertedIconPath("chat.png")       ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"Pidgin"        , "Kopete"         ,}
    } ,
    {
        name        = "Burning",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("burn.png")       ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"k3b"}
    } ,
    {
        name        = "Mail",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
--         screen      = config.data().scr.sec or config.data().scr.pri     ,
        icon        = utils.tools.invertedIconPath("mail2.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Thunderbird"   , "kmail"          , "evolution" ,}
    } ,
    {
        name        = "IRC",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = config.data().scr.irc or config.data().scr.pri     ,
        init        = true                                           ,
        spawn       = "konversation"                                 ,
        icon        = utils.tools.invertedIconPath("irc.png")        ,
        force_screen= true                                           ,
        layout      = awful.layout.suit.fair                         ,
        class       = {"Konversation"  , "Botch"          , "WeeChat"   , "weechat"      , "irssi"}
    } ,
    {
        name        = "Test",
        init        = false                                          ,
        position    = 99                                             ,
        exclusive   = false                                          ,
        screen      = config.data().scr.sec or config.data().scr.pri     ,
        leave_kills = true                                           ,
        persist     = true                                           ,
        icon        = utils.tools.invertedIconPath("tools.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {}
    } ,
    {
        name        = "Config",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
        icon        = utils.tools.invertedIconPath("tools.png")      ,
        layout      = awful.layout.suit.max                        ,
        class       = {"Systemsettings", "Kcontrol"       , "gconf-editor"}
    } ,
    {
        name        = "Game",
        init        = false                                          ,
        screen      = config.data().scr.pri                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
        icon        = utils.tools.invertedIconPath("game.png")       ,
        force_screen= true                                           ,
        layout      = awful.layout.suit.max                        ,
        class       = {"sauer_client"  , "Cube 2$"        , "Cube 2: Sauerbraten"        ,}
    } ,
    {
        name        = "Gimp",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
        icon        = utils.tools.invertedIconPath("image.png")      ,
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
        icon        = utils.tools.invertedIconPath("term.png")       ,
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
        icon        = utils.tools.invertedIconPath("video.png")      ,
        max_clients = 5                                              ,
        screen      = config.data().scr.media or config.data().scr.pri   ,
        init        = "mythfrontend"                                 ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"mythfrontend"  , "xbmc"           ,}
    } ,
    }
tyranic.properties.intrusive = {
    "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"           ,
    "feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color",
    "kcolorchooser" , "plasmoidviewer" , "plasmaengineexplorer" , "Xephyr" , "kruler"     ,
}
tyranic.properties.floating = {
    "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" 
}

tyranic.properties.ontop = {
    "Xephyr"       , "ksnapshot"       , "kruler"
}

tyranic.properties.size_hints_honor = { xterm = false, URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false}
