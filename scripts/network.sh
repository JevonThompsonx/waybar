#!/bin/bash
# Network status script for waybar (JSON output)
# Icons use Nerd Font PUA codepoints rendered by FiraCode Nerd Font.

WIFI_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2)
WIFI_SIGNAL=$(nmcli -t -f active,signal dev wifi | grep '^yes:' | cut -d: -f2)

# Nerd Font glyphs (UTF-8 hex bytes):
#   WiFi:     U+F1EB  = \xef\x87\xab
#   Ethernet: U+F6AB  = \xef\x9a\xab
#   Offline:  U+F0312 = \xf7\xb0\x8c\x92

wifi_icon=$(printf '\xef\x87\xab')
eth_icon=$(printf '\xef\x9a\xab')
off_icon=$(printf '\xf7\xb0\x8c\x92')

if [[ -n "$WIFI_SSID" ]]; then
    printf '{"text":"%s %s%%","tooltip":"WiFi: %s (%s%%)"}\n' \
        "$wifi_icon" "$WIFI_SIGNAL" "$WIFI_SSID" "$WIFI_SIGNAL"
else
    ETH_CONN=$(nmcli -t -f type,state dev | grep 'ethernet:connected' | head -1)
    if [[ -n "$ETH_CONN" ]]; then
        printf '{"text":"%s connected","tooltip":"Ethernet connected"}\n' "$eth_icon"
    else
        printf '{"text":"%s offline","tooltip":"No network connection"}\n' "$off_icon"
    fi
fi
