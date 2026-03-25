#!/usr/bin/env bash
set -euo pipefail

CASE="${1:?Usage: ./run.sh <case_folder>}"
OUT="./output"

mkdir -p "$OUT"

echo "=== Validam Engine v3 ==="
echo ""

# Stage 1: Ingest — hash and index all files
python3 -m core.ingest "$CASE" "$OUT"

# Stage 2: Extract — OCR + text extraction
python3 -m core.extract "$OUT/ingest_index.json" "$OUT"

# Stage 3: Classify — tag each document
python3 -m core.classify "$OUT/extracted.json" "$OUT"

# Stage 4: Entities — extract people, orgs, dates, roles
python3 -m core.entities "$OUT/extracted.json" "$OUT"

# Stage 5: Audit — rule engine over classifications
python3 -m core.audit "$OUT/classified.json" "$OUT"

# Stage 6: Detect — entity-aware contradiction engine
python3 -m core.detect "$OUT/enriched.json" "$OUT"

# Stage 7: Graph — build relationship graph
python3 -m core.graph "$OUT/enriched.json" "$OUT"

# Stage 8: Timeline — reconstruct events with gap detection
python3 -m core.link "$OUT/enriched.json" "$OUT"

# Stage 9: Score — severity scoring
python3 -m core.score "$OUT/contradictions.json" "$OUT/graph.json" "$OUT/timeline.json" "$OUT"

# Stage 10: Dossier — regulator-ready forensic report
python3 -m core.dossier "$OUT/audit_report.json" "$OUT/timeline.json" "$OUT/contradictions.json" "$OUT/classified.json" "$OUT/graph.json" "$OUT/score.json" "$OUT"

echo ""
echo "=== Validam Engine v3 complete ==="
echo "Output: $OUT/dossier.md"
