# core/detect.py — v3 contradiction engine (entity-aware)

import json


def detect_contradictions(enriched, output_path):
    contradictions = []

    media_refs = []
    consent_refs = []
    clinical_refs = []
    sar_refs = []

    consent_dates = []
    media_dates = []

    for item in enriched:
        text = item["text"].lower()
        path = item["path"]
        dates = item.get("entities", {}).get("dates", [])

        if any(kw in text for kw in ("documentary", "filming", "broadcast")):
            media_refs.append(path)
            media_dates.extend(dates)

        if any(kw in text for kw in ("participant information sheet", "informed consent")):
            consent_refs.append(path)
            consent_dates.extend(dates)

        if any(kw in text for kw in ("clinic", "patient", "medical record")):
            clinical_refs.append(path)

        if any(kw in text for kw in ("subject access request", "data protection")):
            sar_refs.append(path)

    # Rule 1: Media without consent
    if media_refs and not consent_refs:
        contradictions.append({
            "type": "MEDIA_WITHOUT_VISIBLE_CONSENT",
            "severity": "HIGH",
            "description": "Media/filming evidence found but no consent documents in bundle",
            "files": media_refs
        })

    # Rule 2: SAR without clinical
    if sar_refs and not clinical_refs:
        contradictions.append({
            "type": "SAR_WITHOUT_CLINICAL_RECORDS",
            "severity": "MEDIUM",
            "description": "Subject access request filed but no clinical records present",
            "files": sar_refs
        })

    # Rule 3: Clinical without consent
    if clinical_refs and not consent_refs:
        contradictions.append({
            "type": "CLINICAL_WITHOUT_CONSENT",
            "severity": "HIGH",
            "description": "Clinical records present but no consent documentation found",
            "files": clinical_refs
        })

    # Rule 4 (v3): Consent latency — consent doc dates vs media activity dates
    if consent_dates and media_dates:
        contradictions.append({
            "type": "CONSENT_LATENCY",
            "severity": "HIGH",
            "description": f"Consent dates ({', '.join(consent_dates[:3])}) may predate or postdate media activity ({', '.join(media_dates[:3])}) — requires manual verification",
            "files": consent_refs + media_refs
        })

    # Rule 5 (v3): Cross-document entity conflict
    # Find people mentioned in both consent and media docs
    consent_people = set()
    media_people = set()
    for item in enriched:
        text = item["text"].lower()
        people = item.get("entities", {}).get("people", [])
        if any(kw in text for kw in ("participant information sheet", "informed consent")):
            consent_people.update(people)
        if any(kw in text for kw in ("documentary", "filming", "broadcast")):
            media_people.update(people)

    if media_people and consent_people:
        unconsented = media_people - consent_people
        if unconsented:
            contradictions.append({
                "type": "PERSON_IN_MEDIA_NOT_IN_CONSENT",
                "severity": "CRITICAL",
                "description": f"People in media docs not found in consent docs: {', '.join(unconsented)}",
                "files": media_refs
            })

    with open(f"{output_path}/contradictions.json", "w") as f:
        json.dump(contradictions, f, indent=2)

    print(f"[DETECT v3] {len(contradictions)} contradiction(s)")


if __name__ == "__main__":
    import sys
    data = json.load(open(sys.argv[1]))
    detect_contradictions(data, sys.argv[2])
