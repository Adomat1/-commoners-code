# core/dossier.py — v3 regulator-ready forensic dossier

import json
from datetime import datetime


def build_dossier(audit_path, timeline_path, contradictions_path,
                  classified_path, graph_path, score_path, output_path):
    with open(audit_path) as f:
        audit = json.load(f)
    with open(timeline_path) as f:
        timeline = json.load(f)
    with open(contradictions_path) as f:
        contradictions = json.load(f)
    with open(classified_path) as f:
        classified = json.load(f)
    with open(graph_path) as f:
        graph = json.load(f)
    with open(score_path) as f:
        score = json.load(f)

    with open(f"{output_path}/dossier.md", "w") as out:
        # Header
        out.write("# VALIDAM FORENSIC DOSSIER\n\n")
        out.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        out.write("---\n\n")

        # Executive summary
        out.write("## Executive Summary\n\n")
        out.write(f"- **Documents analysed:** {audit['total_docs']}\n")
        out.write(f"- **Risk score:** {score['total_score']} ({score['risk_level']})\n")
        out.write(f"- **Audit issues:** {len(audit['issues'])}")
        if audit.get("critical_count"):
            out.write(f" ({audit['critical_count']} critical)")
        out.write("\n")
        out.write(f"- **Contradictions:** {len(contradictions)}\n")
        out.write(f"- **Entity graph:** {graph['stats']['total_nodes']} nodes, {graph['stats']['total_edges']} edges\n")
        out.write(f"- **Cross-file entities:** {graph['stats']['cross_file_entities']}\n")
        out.write(f"- **Timeline events:** {timeline['total_dated']} dated, {timeline['total_undated']} undated\n")
        if timeline["gaps"]:
            out.write(f"- **Timeline gaps:** {len(timeline['gaps'])} (>90 days)\n")
        out.write("\n---\n\n")

        # Document classification
        out.write("## Document Classification\n\n")
        out.write("| Category | Count |\n|----------|-------|\n")
        for tag, count in audit.get("tag_summary", {}).items():
            out.write(f"| {tag} | {count} |\n")
        out.write("\n")

        # Contradictions (SMOKING GUNS)
        out.write("## Contradictions & Violations\n\n")
        if contradictions:
            for c in contradictions:
                out.write(f"### [{c['severity']}] {c['type']}\n\n")
                out.write(f"{c.get('description', '')}\n\n")
                out.write("**Evidence files:**\n")
                for fp in c.get("files", []):
                    out.write(f"- `{fp}`\n")
                out.write("\n")
        else:
            out.write("No contradictions detected.\n\n")

        # Audit findings
        out.write("## Audit Findings\n\n")
        if audit["issues"]:
            for issue in audit["issues"]:
                out.write(f"- **[{issue['severity']}]** {issue['rule']}: {issue['detail']}\n")
        else:
            out.write("No issues detected.\n")
        out.write("\n")

        # Risk score breakdown
        out.write("## Risk Score Breakdown\n\n")
        out.write(f"**Total: {score['total_score']}** — **{score['risk_level']}**\n\n")
        if score.get("breakdown"):
            out.write("| Source | Points | Severity |\n|--------|--------|----------|\n")
            for b in score["breakdown"]:
                out.write(f"| {b['source']} | {b['points']} | {b['severity']} |\n")
        out.write("\n")

        # Entity graph summary
        out.write("## Entity Graph\n\n")
        cross = graph.get("cross_file_links", [])
        if cross:
            out.write("**Cross-file entities** (people appearing in multiple documents):\n\n")
            for link in cross:
                out.write(f"- **{link['person']}** ({link['link_strength']} documents)\n")
                for fp in link["appears_in"]:
                    out.write(f"  - `{fp}`\n")
            out.write("\n")
        else:
            out.write("No cross-file entity links detected.\n\n")

        # Timeline
        out.write("## Reconstructed Timeline\n\n")
        events = timeline.get("events", [])
        dated_events = [e for e in events if e.get("date_raw")]
        if dated_events:
            out.write("| Date | Source | People |\n|------|--------|--------|\n")
            for e in dated_events:
                people_str = ", ".join(e.get("people", [])[:3]) or "—"
                out.write(f"| {e['date_raw']} | `{e['source']}` | {people_str} |\n")
        else:
            out.write("No dated events found.\n")
        out.write("\n")

        # Timeline gaps
        if timeline["gaps"]:
            out.write("### Timeline Gaps (>90 days)\n\n")
            for gap in timeline["gaps"]:
                out.write(f"- **{gap['gap_days']} days** between `{gap['from_date']}` and `{gap['to_date']}`\n")
                out.write(f"  - Files: `{gap['between'][0]}` → `{gap['between'][1]}`\n")
            out.write("\n")

        # Footer
        out.write("---\n\n")
        out.write("*Generated by Validam Engine v3*\n")

    print("[DOSSIER v3] Built")


if __name__ == "__main__":
    import sys
    build_dossier(
        sys.argv[1], sys.argv[2], sys.argv[3],
        sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7]
    )
