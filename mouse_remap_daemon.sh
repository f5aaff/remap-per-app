#!/usr/bin/env bash

CONFIG="$HOME/.config/mouse-remap.conf"
STATE_DIR="/tmp/mouse_remap"
rm -rf "$STATE_DIR" > /dev/null
mkdir -p "$STATE_DIR"

declare -A STATE

DEBUG="${DEBUG:-0}"

log() {
    local level="$1"
    shift
    if [[ "$level" == "DEBUG" && "$DEBUG" != "1" ]]; then
        return
    fi
    echo "[$level] $(date '+%F %T') $*"
}

# Parse buttons into xbindkeys format
parse_buttons() {
    local line="$1"
    echo "$line" | tr ',' '\n' | while read -r mapping; do
        local btn=$(echo "$mapping" | cut -d'=' -f1 | xargs)
        local key=$(echo "$mapping" | cut -d'=' -f2 | xargs)
        echo "\"xdotool key --clearmodifiers $key\""
        echo "$btn"
    done
}

# Generate xbindkeys config for an app
generate_xbindkeys_config() {
    local app="$1"
    local buttons="$2"
    local file="$STATE_DIR/$app.scm"
    > "$file"
    parse_buttons "$buttons" >> "$file"
    echo "$file"
}

log INFO "Starting mouse remap daemon using config: $CONFIG"

while true; do
    match=""
    app=""
    buttons=""

    while IFS= read -r line; do
        # Detect [Section]
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            app="${BASH_REMATCH[1]}"
            match=""
            buttons=""
        elif [[ "$line" =~ ^match ]]; then
            match=$(echo "$line" | cut -d'=' -f2- | xargs)
        elif [[ "$line" =~ ^buttons ]]; then
            buttons=$(echo "$line" | cut -d'=' -f2- | xargs)

            if [[ -z "$match" ]]; then
                match="$app" # fallback to section name
            fi


            # Determine if process is running
            if pgrep -f -- "$match" >/dev/null; then
                if [[ "${STATE[$app]}" != "active" ]]; then
                    log INFO "Found process for [$app]"
                    if [ ! -f "$STATE_DIR/$app.pid" ]; then
                        config_file=$(generate_xbindkeys_config "$app" "$buttons")
                        if xbindkeys -f "$config_file" & then
                            echo $! > "$STATE_DIR/$app.pid"
                            log INFO "Applied remap for [$app] using $config_file"
                        else
                            log ERROR "Failed to start xbindkeys for [$app]"
                        fi
                    fi
                    STATE[$app]="active"
                fi
            else
                if [[ "${STATE[$app]}" != "inactive" ]]; then
                    log INFO "No process found for [$app] (removing remap if active)"
                    if [ -f "$STATE_DIR/$app.pid" ]; then
                        kill $(cat "$STATE_DIR/$app.pid") 2>/dev/null
                        rm "$STATE_DIR/$app.pid"
                        log INFO "Removed remap for [$app]"
                    fi
                    STATE[$app]="inactive"
                fi
            fi
        fi
    done < "$CONFIG"

    sleep 2
done

