#!/bin/bash
set -euo pipefail

LOG_FILE="prepare_artifact.log"
rm -f "$LOG_FILE"

echo "=== Starting artifact preparation ==="
SECONDS=0

run_script() {
    local script_path="$1"
    local script_name
    local step_start

    script_name=$(basename "$script_path")
    step_start=$SECONDS

    if ! bash "$script_path" >> "$LOG_FILE" 2>&1; then
        echo "ERROR: $script_name failed. Check $LOG_FILE for details."
        exit 1
    fi

    echo "$script_name completed in $((SECONDS - step_start)) seconds"
}

# install dependencies
echo "--- Installing dependencies ---"
run_script scripts/init_server.sh

# create checkpoints
echo "--- Creating checkpoints ---"
run_script experiments/create_ckpt.sh
run_script experiments/create_ckpt_scale_global.sh  # for scaling macrobenchmark
run_script experiments/create_ckpt_dyn_global.sh    # for dynamic macrobenchmark

# download and preprocess traces
echo "--- Downloading and preprocessing traces ---"
run_script replay/download_preprocess_trace.sh
run_script replay/trim_cache.sh

echo "=== Total preparation time: $SECONDS seconds ==="
