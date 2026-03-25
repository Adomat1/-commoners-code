#!/usr/bin/env bash
set -euo pipefail

CASE="${1:?Usage: ./run.sh <case_folder>}"
OUT="./output"

mkdir -p "$OUT"

python3 -m core.ingest "$CASE" "$OUT"
python3 -m core.audit "$OUT/ingest_index.json" "$OUT"
python3 -m core.link "$OUT/ingest_index.json" "$OUT"
python3 -m core.dossier "$OUT/audit_report.json" "$OUT/timeline.json" "$OUT"

echo "Validam Engine run complete"
