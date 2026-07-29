#!/bin/bash
# Power menu script for wofi (wayland-native)
# Icons use Nerd Font PUA codepoints rendered by FiraCode Nerd Font.

# Nerd Font glyphs (UTF-8 hex bytes):
#   Power:  U+F704 = \xef\x9c\x84
#   Reboot: U+F49B = \xef\x92\x9b
#   Lock:   U+F023 = \xef\x80\xa3
#   Logout: U+F52B = \xef\x94\xab

power_icon=$(printf '\xef\x9c\x84')
reboot_icon=$(printf '\xef\x92\x9b')
lock_icon=$(printf '\xef\x80\xa3')
logout_icon=$(printf '\xef\x94\xab')

CHOSEN=$(printf '%s\n' \
    "${power_icon} Shutdown" \
    "${reboot_icon} Reboot" \
    "${lock_icon} Lock" \
    "${logout_icon} Logout" | wofi --dmenu --prompt 'Power' --insensitive --width 300 --lines 4)

case "$CHOSEN" in
    *Shutdown*)
        systemctl poweroff
        ;;
    *Reboot*)
        systemctl reboot
        ;;
    *Lock*)
        swaylock -c 000000
        ;;
    *Logout*)
        swaymsg exit
        ;;
esac
