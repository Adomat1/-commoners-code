# core/dossier.py

import json


def build_dossier(audit_path, timeline_path, output_path):
    with open(audit_path) as f:
        audit = json.load(f)

    with open(timeline_path) as f:
        timeline = json.load(f)

    with open(f"{output_path}/dossier.md", "w") as out:
        out.write("# Validam Dossier\n\n")
        out.write(f"Total Files: {audit['total_files']}\n\n")

        out.write("## Timeline\n")
        for t in timeline:
            out.write(f"- {t['file']}\n")

    print("[DOSSIER] Built")


if __name__ == "__main__":
    import sys
    build_dossier(sys.argv[1], sys.argv[2], sys.argv[3])
