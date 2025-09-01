#!/usr/bin/env bash

CONFIG="$HOME/.config/mouse-remap.conf"
STATE_DIR="/tmp/mouse_remap"
mkdir -p "$STATE_DIR"

# this, as it states, parses the buttons from the mapping.
# definitely requires xdotool
parse_buttons() {
    local line="$1"
    echo "$line" | tr ',' '\n' | while read -r mapping; do
        local btn=$(echo "$mapping" | cut -d'=' -f1 | xargs)
        local key=$(echo "$mapping" | cut -d'=' -f2 | xargs)
        echo "\"xdotool key $key\""
        echo "$btn"
        echo
    done
}

# this generates the input for xbindkeys
# obviously, requires xbindkeys
generate_xbindkeys_config() {
    local app="$1"
    local buttons="$2"
    local file="$STATE_DIR/$app.scm"
    > "$file"
    parse_buttons "$buttons" >> "$file"
    echo "$file"
}

# the actual service proper
# matches against the given 'match' field in the config,
# e.g RuneLite or what have you
while true; do
    while IFS= read -r line; do
        # match for process name
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            app="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^buttons ]]; then
            # match against buttons
            buttons=$(echo "$line" | cut -d'=' -f2- | xargs)
            if pgrep -f "$match" >/dev/null; then
                # app is running, ensure remap
                if [ ! -f "$STATE_DIR/$app.pid" ]; then
                    config_file=$(generate_xbindkeys_config "$app" "$buttons")
                    xbindkeys -f "$config_file" &
                    echo $! > "$STATE_DIR/$app.pid"
                    echo "Applied remap for $app"
                fi
            else
                # app is not running, kill remap if exists
                if [ -f "$STATE_DIR/$app.pid" ]; then
                    kill $(cat "$STATE_DIR/$app.pid") 2>/dev/null
                    rm "$STATE_DIR/$app.pid"
                    echo "Removed remap for $app"
                fi
            fi
        fi
    done < "$CONFIG"
    sleep 2
done

