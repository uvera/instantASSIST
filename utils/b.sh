#!/usr/bin/env bash

# assist: adjust display brightness

if [ -e /sys/class/backlight/ ] && [ "$(ls /sys/class/backlight | wc -l)" = "1" ]; then
    BGPU="/sys/class/backlight/$(ls /sys/class/backlight/)"
    MAXBRIGHT=$(cat "$BGPU/max_brightness")
    INSTANTOS_BRIGHTSTEP=${INSTANTOS_BRIGHTSTEP:-$(($MAXBRIGHT / 20))}
else
    if [ -z "$NOBRIGHTMESSAGE" ]; then
        notify-send '[instantASSIST] setting brightness is not supported on this device'
    fi
    echo "system doesn't support brightness changing or you ran into a bug here"
    exit 1
fi

if iconf -i hasnvidia; then
    NVIDIA=true
fi

syncbright() {
    if [ -n "$NVIDIA" ]; then
        light -S "$1"
    else
        echo "$1" >"$BGPU/brightness"
    fi
}

brightness() {

    BRIGHTNESS="$(cat "$BGPU"/brightness)"
    case "$1" in
    -inc)

        bright=$((BRIGHTNESS + $2))
        echo "$bright"
        if [ $bright -lt "$MAXBRIGHT" ] && [ $bright -gt 0 ]; then
            syncbright "$bright"
        fi
        ;;
    -dec)
        bright=$((BRIGHTNESS - $2))
        if [ "$bright" -lt "$MAXBRIGHT" ] && [ $bright -gt 0 ]; then
            syncbright "$bright"
        fi
        ;;

    -set)
        if [ "$2" -lt "$MAXBRIGHT" ] && [ "$2" -gt 0 ]; then
            syncbright "$2"
        fi
        ;;

    *)
        return
        ;;

    esac

}

# argument handling before instantmenu
if [ -n "$1" ]; then
    if ! grep -Eq '^(\+|-|[0-9]|g|m)$' <<<"$1"; then
        exit
    fi

    case "$1" in
    "+")
        brightness -inc "${INSTANTOS_BRIGHTSTEP:-5}"
        ;;
    "-")

        brightness -dec "${INSTANTOS_BRIGHTSTEP:-5}"
        ;;
    g)
        cat "$BGPU/brightness"
        ;;
    m)
        echo "$MAXBRIGHT"
        ;;
    *)
        if [ "$2" = 0 ]; then
            NEWBRIGHT=1
        elif [ -n "$2" ]; then
            NEWBRIGHT=$2
        else
            NEWBRIGHT=50
        fi
        brightness -set "$NEWBRIGHT"
        ;;
    esac
    exit
fi
