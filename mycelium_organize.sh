#!/bin/zsh
# ==============================================================================
# SCRIPT: MYCELIUM_ORGANIZE.sh
# TARGET: /Volumes/Habitat/Mycelium
# OBJECTIVE: Organize SAR subsets and flag incomplete documents
# ==============================================================================
set -euo pipefail

BASE_DIR="/Volumes/Habitat/Mycelium"
EVIDENCE_DIR="$BASE_DIR/Evidence"
REPORT_DIR="$BASE_DIR/Reports"
LOG_FILE="$BASE_DIR/mycelium_organize.log"

# Guard: ensure the volume is mounted and base dir exists
if [[ ! -d "$BASE_DIR" ]]; then
    echo "[ERROR] Base directory not found: $BASE_DIR" >&2
    exit 1
fi

mkdir -p "$EVIDENCE_DIR" "$REPORT_DIR"

log() { echo "$1" | tee -a "$LOG_FILE"; }

log "=== Run started: $(date) ==="

# Enable nullglob so an empty Evidence dir doesn't pass a literal glob string
setopt nullglob

processed=0
flagged=0

for file in "$EVIDENCE_DIR"/*.txt; do
    [[ -f "$file" ]] || continue  # extra safety; nullglob makes this rare
    (( processed++ ))
    name="$(basename "$file")"
    dest="$REPORT_DIR/Incomplete_$name"

    # N1-HIT: page marker present (BRE +) but no salutation found
    if grep -qE "Page [0-9]+ of [0-9]+" "$file" && ! grep -q "Dear" "$file"; then
        # Avoid silent overwrites
        if [[ -e "$dest" ]]; then
            dest="$REPORT_DIR/Incomplete_$(date +%s)_$name"
        fi
        log "[N1-HIT] Incomplete: $name  ->  $(basename "$dest")"
        mv "$file" "$dest"
        (( flagged++ ))
    else
        log "[VALID]  Intact sequence: $name"
    fi
done

log "=== Complete: $processed file(s) processed, $flagged flagged. ==="
