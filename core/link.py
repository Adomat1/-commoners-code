# core/link.py — v3 timeline reconstruction

import json
import re
from datetime import datetime

MONTHS = {
    "january": 1, "february": 2, "march": 3, "april": 4,
    "may": 5, "june": 6, "july": 7, "august": 8,
    "september": 9, "october": 10, "november": 11, "december": 12,
}


def normalize_date(date_str):
    """Try to parse a date string into YYYY-MM-DD for sorting."""
    # ISO format: 2024-03-15
    m = re.match(r"^(\d{4})-(\d{2})-(\d{2})$", date_str)
    if m:
        return date_str

    # UK format: 15/03/2024
    m = re.match(r"^(\d{1,2})/(\d{1,2})/(\d{4})$", date_str)
    if m:
        return f"{m.group(3)}-{m.group(2).zfill(2)}-{m.group(1).zfill(2)}"

    # Long form: 15 March 2024
    m = re.match(r"^(\d{1,2})\s+(\w+)\s+(\d{4})$", date_str)
    if m:
        month = MONTHS.get(m.group(2).lower())
        if month:
            return f"{m.group(3)}-{str(month).zfill(2)}-{m.group(1).zfill(2)}"

    # US form: March 15, 2024
    m = re.match(r"^(\w+)\s+(\d{1,2}),?\s+(\d{4})$", date_str)
    if m:
        month = MONTHS.get(m.group(1).lower())
        if month:
            return f"{m.group(3)}-{str(month).zfill(2)}-{m.group(2).zfill(2)}"

    return None


def build_timeline(enriched, output_path):
    events = []

    for item in enriched:
        dates = item.get("entities", {}).get("dates", [])
        people = item.get("entities", {}).get("people", [])
        path = item["path"]

        if dates:
            for date_str in dates:
                normalized = normalize_date(date_str)
                events.append({
                    "date_raw": date_str,
                    "date_sort": normalized or "9999-99-99",
                    "source": path,
                    "people": people,
                    "event": "DATE_REFERENCED"
                })
        else:
            # Still include file as undated event
            events.append({
                "date_raw": None,
                "date_sort": "9999-99-99",
                "source": path,
                "people": people,
                "event": "FILE_DISCOVERED_UNDATED"
            })

    # Sort by normalized date
    events.sort(key=lambda x: x["date_sort"])

    # Detect gaps > 90 days between consecutive dated events
    gaps = []
    dated = [e for e in events if e["date_sort"] != "9999-99-99"]
    for i in range(1, len(dated)):
        try:
            d1 = datetime.strptime(dated[i - 1]["date_sort"], "%Y-%m-%d")
            d2 = datetime.strptime(dated[i]["date_sort"], "%Y-%m-%d")
            delta = abs((d2 - d1).days)
            if delta > 90:
                gaps.append({
                    "between": [dated[i - 1]["source"], dated[i]["source"]],
                    "gap_days": delta,
                    "from_date": dated[i - 1]["date_sort"],
                    "to_date": dated[i]["date_sort"]
                })
        except (ValueError, TypeError):
            continue

    timeline = {
        "events": events,
        "gaps": gaps,
        "total_dated": len(dated),
        "total_undated": len(events) - len(dated)
    }

    with open(f"{output_path}/timeline.json", "w") as f:
        json.dump(timeline, f, indent=2)

    print(f"[TIMELINE v3] {len(dated)} dated, {len(events) - len(dated)} undated, {len(gaps)} gap(s)")


if __name__ == "__main__":
    import sys
    data = json.load(open(sys.argv[1]))
    build_timeline(data, sys.argv[2])
