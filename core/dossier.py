# core/dossier.py — v2 structured findings

import json
from datetime import datetime


def build_dossier(audit_path, timeline_path, contradictions_path, classified_path, output_path):
    with open(audit_path) as f:
        audit = json.load(f)

    with open(timeline_path) as f:
        timeline = json.load(f)

    with open(contradictions_path) as f:
        contradictions = json.load(f)

    with open(classified_path) as f:
        classified = json.load(f)

    with open(f"{output_path}/dossier.md", "w") as out:
        out.write("# Validam — Evidence Dossier\n\n")
        out.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        out.write(f"Total Documents: {audit['total_docs']}\n\n")

        # Tag summary
        out.write("## Document Classification\n\n")
        out.write("| Category | Count |\n|----------|-------|\n")
        for tag, count in audit.get("tag_summary", {}).items():
            out.write(f"| {tag} | {count} |\n")
        out.write("\n")

        # Audit issues
        out.write("## Audit Findings\n\n")
        if audit["issues"]:
            for issue in audit["issues"]:
                out.write(f"- **[{issue['severity']}]** {issue['rule']}: {issue['detail']}\n")
        else:
            out.write("No issues detected.\n")
        out.write("\n")

        # Contradictions
        out.write("## Contradictions\n\n")
        if contradictions:
            for c in contradictions:
                out.write(f"- **[{c['severity']}]** {c['type']}\n")
                for fp in c["files"]:
                    out.write(f"  - `{fp}`\n")
        else:
            out.write("No contradictions detected.\n")
        out.write("\n")

        # Timeline
        out.write("## Timeline\n\n")
        for t in timeline:
            out.write(f"- `{t['event']}` — {t['file']}\n")

    print("[DOSSIER v2] Built")


if __name__ == "__main__":
    import sys
    build_dossier(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
