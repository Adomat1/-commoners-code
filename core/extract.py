# core/extract.py

import json
import os


def extract_text_from_file(path):
    ext = os.path.splitext(path)[1].lower()

    if ext == ".pdf":
        try:
            from pdfminer.high_level import extract_text
            return extract_text(path)
        except Exception:
            return ""

    if ext in (".png", ".jpg", ".jpeg", ".tiff", ".bmp"):
        try:
            import pytesseract
            from PIL import Image
            return pytesseract.image_to_string(Image.open(path))
        except Exception:
            return ""

    if ext in (".txt", ".csv", ".md", ".log"):
        try:
            with open(path, "r", errors="replace") as f:
                return f.read()
        except Exception:
            return ""

    return ""


def run_extract(index, output_path):
    results = []

    for item in index:
        text = extract_text_from_file(item["path"])
        results.append({
            "path": item["path"],
            "hash": item.get("hash", ""),
            "text": text[:5000]
        })

    with open(f"{output_path}/extracted.json", "w") as f:
        json.dump(results, f, indent=2)

    print(f"[EXTRACT] Processed {len(results)} files")


if __name__ == "__main__":
    import sys
    index = json.load(open(sys.argv[1]))
    run_extract(index, sys.argv[2])
