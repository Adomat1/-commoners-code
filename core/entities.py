# core/entities.py — v3 entity extraction

import re
import json

# Month names for date parsing
MONTHS = (
    "january", "february", "march", "april", "may", "june",
    "july", "august", "september", "october", "november", "december"
)

MONTH_PATTERN = "|".join(m.capitalize() for m in MONTHS)

# Date patterns: "15 March 2024", "March 15, 2024", "2024-03-15", "15/03/2024"
DATE_PATTERNS = [
    re.compile(rf"\b(\d{{1,2}}\s+(?:{MONTH_PATTERN})\s+\d{{4}})\b"),
    re.compile(rf"\b((?:{MONTH_PATTERN})\s+\d{{1,2}},?\s+\d{{4}})\b"),
    re.compile(r"\b(\d{4}-\d{2}-\d{2})\b"),
    re.compile(r"\b(\d{1,2}/\d{1,2}/\d{4})\b"),
]

# Person names: two or more capitalized words on the same line (no newline spans)
PERSON_PATTERN = re.compile(r"\b([A-Z][a-z]{1,20}[ \t]+[A-Z][a-z]{1,20}(?:[ \t]+[A-Z][a-z]{1,20})?)\b")

# Known org keywords
ORG_KEYWORDS = [
    "NHS", "University", "Hospital", "Trust", "Council",
    "Police", "BBC", "ITV", "Channel 4", "ICO",
    "CQC", "GMC", "HCPC", "Ministry", "Department",
]

# Role keywords
ROLE_KEYWORDS = [
    "doctor", "nurse", "consultant", "solicitor", "barrister",
    "judge", "registrar", "manager", "director", "officer",
    "patient", "claimant", "respondent", "complainant", "witness",
]


def extract_entities(text):
    entities = {
        "people": [],
        "dates": [],
        "orgs": [],
        "roles": [],
    }

    # Dates
    for pattern in DATE_PATTERNS:
        for match in pattern.findall(text):
            date_str = match if isinstance(match, str) else match[0]
            if date_str not in entities["dates"]:
                entities["dates"].append(date_str)

    # People
    FALSE_STARTS = {
        "the", "this", "that", "dear", "yours", "from", "to", "subject",
        "sent", "date", "hi", "location", "reference", "under", "regarding",
        "follow", "broadcast", "production", "filming", "documentary",
        "clinical", "medical", "data", "participant", "information",
    }
    for match in PERSON_PATTERN.findall(text):
        first_word = match.split()[0].lower()
        if first_word not in FALSE_STARTS:
            if match not in entities["people"]:
                entities["people"].append(match)

    # Orgs
    text_upper = text
    for kw in ORG_KEYWORDS:
        if kw.lower() in text.lower():
            # Try to grab the full org name (keyword + surrounding context)
            pattern = re.compile(rf"\b([A-Z][\w\s]{{0,40}}{re.escape(kw)}[\w\s]{{0,20}})\b")
            matches = pattern.findall(text_upper)
            if matches:
                for m in matches:
                    clean = m.strip()
                    if clean and clean not in entities["orgs"]:
                        entities["orgs"].append(clean)
            elif kw not in entities["orgs"]:
                entities["orgs"].append(kw)

    # Roles
    text_lower = text.lower()
    for role in ROLE_KEYWORDS:
        if role in text_lower:
            if role not in entities["roles"]:
                entities["roles"].append(role)

    return entities


def run_entities(extracted, output_path):
    enriched = []

    all_people = set()
    all_orgs = set()
    all_dates = set()

    for item in extracted:
        ents = extract_entities(item["text"])
        enriched.append({
            "path": item["path"],
            "hash": item.get("hash", ""),
            "text": item["text"],
            "entities": ents,
        })
        all_people.update(ents["people"])
        all_orgs.update(ents["orgs"])
        all_dates.update(ents["dates"])

    with open(f"{output_path}/enriched.json", "w") as f:
        json.dump(enriched, f, indent=2)

    print(f"[ENTITIES] {len(all_people)} people, {len(all_orgs)} orgs, {len(all_dates)} dates")


if __name__ == "__main__":
    import sys
    data = json.load(open(sys.argv[1]))
    run_entities(data, sys.argv[2])
