# core/classify.py

import json


RULES = [
    ("CONSENT",  ["participant information sheet", "informed consent", "consent form"]),
    ("MEDIA",    ["documentary", "filming", "broadcast", "production company"]),
    ("SAR",      ["subject access request", "data protection", "gdpr", "ico"]),
    ("CLINICAL", ["clinic", "patient", "diagnosis", "treatment", "medical record"]),
    ("LEGAL",    ["solicitor", "barrister", "court order", "tribunal", "judgment"]),
    ("EMAIL",    ["from:", "to:", "subject:", "sent:"]),
]


def classify(text):
    text_lower = text.lower()

    for tag, keywords in RULES:
        if any(kw in text_lower for kw in keywords):
            return tag

    return "OTHER"


def run_classify(extracted, output_path):
    results = []

    for item in extracted:
        tag = classify(item["text"])
        results.append({
            "path": item["path"],
            "tag": tag,
            "hash": item.get("hash", "")
        })

    with open(f"{output_path}/classified.json", "w") as f:
        json.dump(results, f, indent=2)

    tag_counts = {}
    for r in results:
        tag_counts[r["tag"]] = tag_counts.get(r["tag"], 0) + 1

    print(f"[CLASSIFY] {len(results)} docs — {tag_counts}")


if __name__ == "__main__":
    import sys
    data = json.load(open(sys.argv[1]))
    run_classify(data, sys.argv[2])
