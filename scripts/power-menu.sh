#!/bin/bash
# ============================================================================
# Power menu for wofi (wayland-native)
# JevonThompsonx/sway → scripts/power-menu.sh
# JevonThompsonx/waybar → scripts/power-menu.sh
# ============================================================================
# Options (top to bottom = most-used to least-used):
#   1. Cancel   — do nothing
#   2. Lock     — swaylock
#   3. Logout   — end sway session
#   4. Suspend  — RAM sleep
#   5. Hibernate — disk sleep
#   6. Reboot   — systemctl reboot
#   7. Shutdown — systemctl poweroff
# ============================================================================
# Icons use Nerd Font PUA codepoints rendered by FiraCode Nerd Font /
# JetBrainsMono Nerd Font. Nerd Font codepoints follow NF-MD (Material Design)
# variant where possible.
#
# Nerd Font glyphs (UTF-8 hex bytes):
#   Cancel:    U+F015  = \xef\x80\x95
#   Lock:      U+F023  = \xef\x80\xa3
#   Logout:    U+F2F5  = \xef\x8b\xb5
#   Suspend:   U+F186  = \xef\x86\x86  (weather-night)
#   Hibernate: U+F2DC  = \xef\x8b\x9c  (heart-pulse)
#   Reboot:    U+F49B  = \xef\x92\x9b  (restore)
#   Shutdown:  U+F704  = \xef\x9c\x84  (power-standby)
# ============================================================================

set -euo pipefail

cancel_icon=$(printf '\xef\x80\x95')
lock_icon=$(printf '\xef\x80\xa3')
logout_icon=$(printf '\xef\x8b\xb5')
suspend_icon=$(printf '\xef\x86\x86')
hibernate_icon=$(printf '\xef\x8b\x9c')
reboot_icon=$(printf '\xef\x92\x9b')
power_icon=$(printf '\xef\x9c\x84')

CHOSEN=$(printf '%s\n' \
    "${cancel_icon} Cancel" \
    "${lock_icon} Lock" \
    "${logout_icon} Logout" \
    "${suspend_icon} Suspend" \
    "${hibernate_icon} Hibernate" \
    "${reboot_icon} Reboot" \
    "${power_icon} Shutdown" \
    | wofi --dmenu --prompt 'Power Menu' --insensitive --width 350 --lines 7)

# Match by action keyword (case insensitive)
case "$CHOSEN" in
    *Cancel*|*cancel*)
        exit 0
        ;;
    *Lock*|*lock*)
        swaylock -c 000000
        ;;
    *Logout*|*logout*)
        swaymsg exit
        ;;
    *Suspend*|*suspend*)
        systemctl suspend
        ;;
    *Hibernate*|*hibernate*)
        systemctl hibernate
        ;;
    *Reboot*|*reboot*)
        systemctl reboot
        ;;
    *Shutdown*|*shutdown*)
        systemctl poweroff
        ;;
    *)
        # Empty selection or wofi closed (Esc) — do nothing
        exit 0
        ;;
esac
