# core/link.py

import json


def build_timeline(index_path, output_path):
    with open(index_path) as f:
        data = json.load(f)

    timeline = []

    for entry in data[:20]:
        timeline.append({
            "event": "FILE_DISCOVERED",
            "file": entry["path"]
        })

    with open(f"{output_path}/timeline.json", "w") as out:
        json.dump(timeline, out, indent=2)

    print("[LINK] Timeline created")


if __name__ == "__main__":
    import sys
    build_timeline(sys.argv[1], sys.argv[2])
