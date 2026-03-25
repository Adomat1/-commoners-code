#!/usr/bin/env bash
set -euo pipefail

CASE="${1:?Usage: ./run.sh <case_folder>}"
OUT="./output"

mkdir -p "$OUT"

echo "=== Validam Engine v2 ==="
echo ""

# Stage 1: Ingest — hash and index all files
python3 -m core.ingest "$CASE" "$OUT"

# Stage 2: Extract — OCR + text extraction
python3 -m core.extract "$OUT/ingest_index.json" "$OUT"

# Stage 3: Classify — tag each document
python3 -m core.classify "$OUT/extracted.json" "$OUT"

# Stage 4: Audit — rule engine over classifications
python3 -m core.audit "$OUT/classified.json" "$OUT"

# Stage 5: Detect — find contradictions in extracted text
python3 -m core.detect "$OUT/extracted.json" "$OUT"

# Stage 6: Link — build timeline
python3 -m core.link "$OUT/ingest_index.json" "$OUT"

# Stage 7: Dossier — structured findings report
python3 -m core.dossier "$OUT/audit_report.json" "$OUT/timeline.json" "$OUT/contradictions.json" "$OUT/classified.json" "$OUT"

echo ""
echo "=== Validam Engine v2 complete ==="
echo "Output: $OUT/dossier.md"
