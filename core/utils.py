# core/utils.py

import hashlib
import os


def hash_file(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        while chunk := f.read(8192):
            h.update(chunk)
    return h.hexdigest()


def list_files(folder):
    files = []
    for root, _, filenames in os.walk(folder):
        for f in filenames:
            files.append(os.path.join(root, f))
    return files
