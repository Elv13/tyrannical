# If example.rc.lua is missing, make a default one.
rc_lua=$PWD/example.rc.lua
test -f $rc_lua || /bin/cp /etc/xdg/awesome/rc.lua $rc_lua

# Just in case we're not running from /usr/bin
awesome=`which awesome`
xephyr=`which Xephyr`
pidof=`which pidof`

test -x $awesome || { echo "Awesome executable not found. Please install Awesome"; exit 1; }
test -x $xephyr || { echo "Xephyr executable not found. Please install Xephyr"; exit 1; }

function usage()
{
  cat <<USAGE
awesome_test start|stop|restart|run

  start    Start nested Awesome in Xephyr
  stop     Stop Xephyr
  restart  Reload nested Awesome configuration
  run      Run command in nested Awesome

USAGE
  exit 0
}

# WARNING: the following two functions expect that you only run one instance
# of Xephyr and the last launched Awesome runs in it

function awesome_pid()
{
  $pidof awesome | cut -d\  -f1
}

function xephyr_pid()

{
  $pidof Xephyr | cut -d\  -f1
}

[ $# -lt 1 ] && usage


case "$1" in
  start)
    $xephyr -ac -br -noreset -screen 800x600 :1 &
    sleep 1
    DISPLAY=:1.0 $awesome -c $rc_lua &
    sleep 1
    echo "Awesome ready for tests. PID is $(awesome_pid)"
    ;;
  stop)
    echo -n "Stopping Nested Awesome... "
    if [ -z $(xephyr_pid) ]; then
      echo "Not running: not stopped :)"
      exit 0
    else
      kill $(xephyr_pid)
      echo "Done."
    fi
    ;;
  restart)
    echo -n "Restarting Awesome... "
    kill -s SIGHUP $(awesome_pid)
    ;;
  run)
    shift
    DISPLAY=:1.0 "$@" &
    ;;
  *)
    usage
    ;;
esac
