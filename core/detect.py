# core/detect.py

import json


def detect_contradictions(extracted, output_path):
    contradictions = []

    media_refs = []
    consent_refs = []
    clinical_refs = []
    sar_refs = []

    for item in extracted:
        text = item["text"].lower()
        path = item["path"]

        if any(kw in text for kw in ("documentary", "filming", "broadcast")):
            media_refs.append(path)

        if any(kw in text for kw in ("participant information sheet", "informed consent")):
            consent_refs.append(path)

        if any(kw in text for kw in ("clinic", "patient", "medical record")):
            clinical_refs.append(path)

        if any(kw in text for kw in ("subject access request", "data protection")):
            sar_refs.append(path)

    # Rule 1: Media evidence exists but no consent paperwork found
    if media_refs and not consent_refs:
        contradictions.append({
            "type": "MEDIA_WITHOUT_VISIBLE_CONSENT",
            "severity": "HIGH",
            "files": media_refs
        })

    # Rule 2: SAR filed but no clinical records in the bundle
    if sar_refs and not clinical_refs:
        contradictions.append({
            "type": "SAR_WITHOUT_CLINICAL_RECORDS",
            "severity": "MEDIUM",
            "files": sar_refs
        })

    # Rule 3: Clinical records present but no consent documents
    if clinical_refs and not consent_refs:
        contradictions.append({
            "type": "CLINICAL_WITHOUT_CONSENT",
            "severity": "HIGH",
            "files": clinical_refs
        })

    with open(f"{output_path}/contradictions.json", "w") as f:
        json.dump(contradictions, f, indent=2)

    print(f"[DETECT] Found {len(contradictions)} contradiction(s)")


if __name__ == "__main__":
    import sys
    data = json.load(open(sys.argv[1]))
    detect_contradictions(data, sys.argv[2])
