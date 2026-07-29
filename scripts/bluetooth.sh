#!/bin/bash
# Bluetooth manager via rofi for waybar
# Shows paired/available devices, connect/disconnect/pair/scan

BT_STATUS=$(bluetoothctl show | grep -q "Powered: yes" && echo "on" || echo "off")

# Ensure discoverable is on when BT is active
[[ "$BT_STATUS" == "on" ]] && bluetoothctl discoverable on >/dev/null 2>&1

get_devices() {
    # Paired/bonded devices
    bluetoothctl devices Paired 2>/dev/null | while read -r _ mac name; do
        connected=$(bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes" && echo "yes" || echo "no")
        if [[ "$connected" == "yes" ]]; then
            printf "  %s [%s]\n" "$name" "$mac"
        else
            printf "  %s [%s]\n" "$name" "$mac"
        fi
    done

    # Trusted but not paired
    bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
        paired=$(bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes" && echo "yes" || echo "no")
        if [[ "$paired" == "no" ]]; then
            printf "  %s [%s]\n" "$name" "$mac"
        fi
    done
}

if [[ "$BT_STATUS" == "off" ]]; then
    CHOSEN=$(echo -e "⏻  Turn Bluetooth On\n  Exit" | rofi -dmenu -i -p "Bluetooth (off)" \
        -theme-str 'window {width: 350px;}')
    case "$CHOSEN" in
        *Turn*On*)
            bluetoothctl power on
            sleep 1
            notify-send "Bluetooth" "Bluetooth turned on" -i bluetooth 2>/dev/null
            ;;
    esac
    exit 0
fi

# Build menu
MENU=""
MENU+="  Scan for devices\n"
MENU+="⏻  Turn Bluetooth Off\n"
MENU+="───────────────────\n"

# Get connected devices
CONNECTED=$(bluetoothctl devices Connected 2>/dev/null)
PAIRED=$(bluetoothctl devices Paired 2>/dev/null)
ALL=$(bluetoothctl devices 2>/dev/null)

# Show connected first
if [[ -n "$CONNECTED" ]]; then
    while read -r _ mac name; do
        MENU+="  ${name} [${mac}]\n"
    done <<< "$CONNECTED"
fi

# Show paired (not connected)
if [[ -n "$PAIRED" ]]; then
    while read -r _ mac name; do
        is_connected=$(echo "$CONNECTED" | grep -c "$mac")
        if [[ "$is_connected" -eq 0 ]]; then
            MENU+="  ${name} [${mac}]\n"
        fi
    done <<< "$PAIRED"
fi

# Show discovered (not paired)
if [[ -n "$ALL" ]]; then
    while read -r _ mac name; do
        is_paired=$(echo "$PAIRED" | grep -c "$mac")
        if [[ "$is_paired" -eq 0 ]]; then
            MENU+="  ${name} [${mac}]\n"
        fi
    done <<< "$ALL"
fi

CHOSEN=$(echo -e "$MENU" | rofi -dmenu -i -p " Bluetooth" \
    -theme-str 'window {width: 450px;} listview {lines: 12;}')

[[ -z "$CHOSEN" ]] && exit 0

case "$CHOSEN" in
    *Scan*)
        notify-send "Bluetooth" "Scanning for devices..." -i bluetooth 2>/dev/null
        bluetoothctl scan on &
        SCAN_PID=$!
        sleep 5
        kill $SCAN_PID 2>/dev/null
        # Re-open with updated list
        exec "$0"
        ;;
    *Turn*Off*)
        bluetoothctl power off
        notify-send "Bluetooth" "Bluetooth turned off" -i bluetooth 2>/dev/null
        exit 0
        ;;
    *────*)
        exit 0
        ;;
    *)
        # Extract MAC address from selection
        MAC=$(echo "$CHOSEN" | grep -oP '\[([0-9A-F:]+)\]' | tr -d '[]')
        [[ -z "$MAC" ]] && exit 0

        # Check if connected
        IS_CONNECTED=$(bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes" && echo "yes" || echo "no")
        IS_PAIRED=$(bluetoothctl info "$MAC" 2>/dev/null | grep -q "Paired: yes" && echo "yes" || echo "no")
        DEVICE_NAME=$(echo "$CHOSEN" | sed 's/.*  //;s/ \[.*//')

        if [[ "$IS_CONNECTED" == "yes" ]]; then
            ACTION=$(echo -e "  Disconnect\n  Unpair\n  Cancel" | rofi -dmenu -i -p "$DEVICE_NAME" \
                -theme-str 'window {width: 300px;}')
            case "$ACTION" in
                *Disconnect*)
                    bluetoothctl disconnect "$MAC"
                    notify-send "Bluetooth" "Disconnected from $DEVICE_NAME" -i bluetooth 2>/dev/null
                    ;;
                *Unpair*)
                    bluetoothctl remove "$MAC"
                    notify-send "Bluetooth" "Removed $DEVICE_NAME" -i bluetooth 2>/dev/null
                    ;;
            esac
        elif [[ "$IS_PAIRED" == "yes" ]]; then
            ACTION=$(echo -e "  Connect\n  Remove\n  Cancel" | rofi -dmenu -i -p "$DEVICE_NAME" \
                -theme-str 'window {width: 300px;}')
            case "$ACTION" in
                *Connect*)
                    bluetoothctl connect "$MAC"
                    sleep 2
                    notify-send "Bluetooth" "Connecting to $DEVICE_NAME..." -i bluetooth 2>/dev/null
                    ;;
                *Remove*)
                    bluetoothctl remove "$MAC"
                    notify-send "Bluetooth" "Removed $DEVICE_NAME" -i bluetooth 2>/dev/null
                    ;;
            esac
        else
            ACTION=$(echo -e "  Pair & Connect\n  Cancel" | rofi -dmenu -i -p "$DEVICE_NAME" \
                -theme-str 'window {width: 300px;}')
            case "$ACTION" in
                *Pair*)
                    bluetoothctl pair "$MAC" && bluetoothctl connect "$MAC"
                    sleep 2
                    notify-send "Bluetooth" "Pairing with $DEVICE_NAME..." -i bluetooth 2>/dev/null
                    ;;
            esac
        fi
        ;;
esac
