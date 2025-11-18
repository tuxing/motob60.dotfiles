#!/bin/bash

# --- CONFIGURATION ---
POWER_CPU_PATH="/sys/class/powercap/intel-rapl:0/energy_uj"
LOG_FILE="/tmp/power_history.log"
TEMP_FILE="/tmp/waybar_temps"
MAX_LINES=900

# --- DYNAMIC SENSOR FINDING ---
# Find the thermal zone file where the type is "x86_pkg_temp" (CPU)
TEMP_CPU_PATH=$(grep -l "x86_pkg_temp" /sys/class/thermal/thermal_zone*/type | sed 's/type/temp/')

# Permission check
if [ ! -r "$POWER_CPU_PATH" ]; then
    echo "Err:Perms"
    exit 1
fi

# Setup files
touch "$LOG_FILE"
touch "$TEMP_FILE"

LAST_VAL=$(cat "$POWER_CPU_PATH")
CLEANUP_COUNTER=0

while true; do
    sleep 2
    
    # --- POWER CALC ---
    CURR_VAL=$(cat "$POWER_CPU_PATH")
    DIFF=$((CURR_VAL - LAST_VAL))
    CPU_W=$(echo "$DIFF" | awk '{printf "%04.1f", $1 / 2000000}')
    TOTAL_W=$(sensors | awk '/power1:/ {printf "%04.1f", $2}')

    # --- TEMP CALC ---
    # Read CPU file, divide by 1000 to get Celsius
    if [ -r "$TEMP_CPU_PATH" ]; then
        RAW_CPU=$(cat "$TEMP_CPU_PATH")
        CPU_T=$((RAW_CPU / 1000))
    else
        CPU_T="?"
    fi

    # --- OUTPUTS ---
    
    # 1. Main Output (Power) -> "04.5/12.2 W"
    echo "${CPU_W}/${TOTAL_W} W"

    # 2. Side Channel (Temp) -> "43°C"
    echo "${CPU_T}°C" > "$TEMP_FILE"

    # 3. Logging -> Time | Power | Temp: 43C
    TIMESTAMP=$(date '+%H:%M:%S')
    echo "$TIMESTAMP | Power: ${CPU_W}/${TOTAL_W}W | Temp: ${CPU_T}C" >> "$LOG_FILE"

    # --- CLEANUP ---
    ((CLEANUP_COUNTER++))
    if [ "$CLEANUP_COUNTER" -ge 10 ]; then
        tail -n "$MAX_LINES" "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
        CLEANUP_COUNTER=0
    fi

    LAST_VAL=$CURR_VAL
done

