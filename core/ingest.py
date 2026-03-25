# core/ingest.py

import json
from core.utils import list_files, hash_file


def ingest(case_path, output_path):
    files = list_files(case_path)
    index = []

    for f in files:
        try:
            file_hash = hash_file(f)
            index.append({
                "path": f,
                "hash": file_hash
            })
        except Exception:
            continue

    with open(f"{output_path}/ingest_index.json", "w") as out:
        json.dump(index, out, indent=2)

    print(f"[INGEST] Indexed {len(index)} files")


if __name__ == "__main__":
    import sys
    ingest(sys.argv[1], sys.argv[2])
