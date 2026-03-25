# core/score.py — v3 severity scoring engine

import json

# Weights per finding type
WEIGHTS = {
    "MEDIA_WITHOUT_VISIBLE_CONSENT": 10,
    "MEDIA_WITHOUT_CONSENT":         10,
    "CONSENT_LATENCY":                8,
    "CLINICAL_WITHOUT_CONSENT":       8,
    "SAR_WITHOUT_CLINICAL_RECORDS":   5,
    "TIMELINE_GAP":                   6,
    "ENTITY_APPEARS_CROSS_FILE":      2,
}


def compute_score(contradictions, graph, timeline):
    score = 0
    breakdown = []

    # Score contradictions
    for c in contradictions:
        weight = WEIGHTS.get(c["type"], 3)
        score += weight
        breakdown.append({
            "source": c["type"],
            "points": weight,
            "severity": c.get("severity", "UNKNOWN")
        })

    # Bonus for cross-file entity links (indicates systemic involvement)
    cross_links = graph.get("cross_file_links", [])
    for link in cross_links:
        if link["link_strength"] >= 3:
            score += WEIGHTS["ENTITY_APPEARS_CROSS_FILE"]
            breakdown.append({
                "source": f"CROSS_FILE: {link['person']}",
                "points": WEIGHTS["ENTITY_APPEARS_CROSS_FILE"],
                "severity": "INFO"
            })

    # Timeline gap detection
    events = timeline.get("events", timeline) if isinstance(timeline, dict) else timeline
    gaps = timeline.get("gaps", []) if isinstance(timeline, dict) else []
    for gap in gaps:
        score += WEIGHTS["TIMELINE_GAP"]
        breakdown.append({
            "source": f"TIMELINE_GAP: {gap.get('gap_days', '?')} days",
            "points": WEIGHTS["TIMELINE_GAP"],
            "severity": "MEDIUM"
        })

    # Risk level
    if score >= 20:
        risk = "CRITICAL"
    elif score >= 10:
        risk = "HIGH"
    elif score >= 5:
        risk = "MEDIUM"
    else:
        risk = "LOW"

    result = {
        "total_score": score,
        "risk_level": risk,
        "breakdown": breakdown
    }

    return result


def run_score(contradictions_path, graph_path, timeline_path, output_path):
    with open(contradictions_path) as f:
        contradictions = json.load(f)
    with open(graph_path) as f:
        graph = json.load(f)
    with open(timeline_path) as f:
        timeline = json.load(f)

    result = compute_score(contradictions, graph, timeline)

    with open(f"{output_path}/score.json", "w") as f:
        json.dump(result, f, indent=2)

    print(f"[SCORE] {result['total_score']} points — {result['risk_level']}")


if __name__ == "__main__":
    import sys
    run_score(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
