# core/audit.py

import json


def audit(index_path, output_path):
    with open(index_path) as f:
        data = json.load(f)

    issues = []

    if len(data) < 10:
        issues.append("LOW_FILE_COUNT")

    with open(f"{output_path}/audit_report.json", "w") as out:
        json.dump({
            "total_files": len(data),
            "issues": issues
        }, out, indent=2)

    print("[AUDIT] Completed")


if __name__ == "__main__":
    import sys
    audit(sys.argv[1], sys.argv[2])
