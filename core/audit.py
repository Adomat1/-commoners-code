# core/audit.py — v2 rule engine

import json


def audit(classified, output_path):
    issues = []
    tags = [x["tag"] for x in classified]

    # Rule 1: Missing consent documentation
    if "CONSENT" not in tags:
        issues.append({
            "rule": "MISSING_CONSENT_DOCUMENT",
            "severity": "HIGH",
            "detail": "No consent or participant information sheet found in bundle"
        })

    # Rule 2: Media present without consent
    if "MEDIA" in tags and "CONSENT" not in tags:
        issues.append({
            "rule": "MEDIA_WITHOUT_CONSENT",
            "severity": "CRITICAL",
            "detail": "Media/filming evidence exists but no consent paperwork found"
        })

    # Rule 3: SAR present but no clinical context
    if "SAR" in tags and "CLINICAL" not in tags:
        issues.append({
            "rule": "SAR_WITHOUT_CLINICAL_CONTEXT",
            "severity": "MEDIUM",
            "detail": "Subject access request filed but no clinical records in bundle"
        })

    # Rule 4: Low file count warning
    if len(classified) < 10:
        issues.append({
            "rule": "LOW_FILE_COUNT",
            "severity": "LOW",
            "detail": f"Only {len(classified)} documents — bundle may be incomplete"
        })

    # Tag summary
    tag_counts = {}
    for x in classified:
        tag_counts[x["tag"]] = tag_counts.get(x["tag"], 0) + 1

    report = {
        "total_docs": len(classified),
        "tag_summary": tag_counts,
        "issues": issues,
        "critical_count": sum(1 for i in issues if i["severity"] == "CRITICAL"),
        "high_count": sum(1 for i in issues if i["severity"] == "HIGH")
    }

    with open(f"{output_path}/audit_report.json", "w") as f:
        json.dump(report, f, indent=2)

    print(f"[AUDIT v2] {len(issues)} issue(s) — {report['critical_count']} critical, {report['high_count']} high")


if __name__ == "__main__":
    import sys
    data = json.load(open(sys.argv[1]))
    audit(data, sys.argv[2])
