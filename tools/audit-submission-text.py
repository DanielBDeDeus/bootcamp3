"""Inspect current repository text and generated PDF text; never rewrite history."""
import json
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root / 'artifacts/python-tools'))
import pymupdf

# Natural-language production/assistance statements, not conceptual coursework.
patterns = [
    r'\b(?:ChatGPT|Codex|Claude|OpenAI|intelig[eê]ncia artificial|IA|AI)\s+(?:foi\s+)?(?:usad[oa]|utilizad[oa]|executad[oa]|auxiliou|ajudou|gerou|produziu)\b',
    r'\b(?:gerad[oa]s?|produzid[oa]s?|criad[oa]s?|executad[oa]s?)\s+(?:por|com)\s+(?:ChatGPT|Codex|IA|AI)\b',
    r'\b(?:ChatGPT|Codex)\s*:\s*apoio\b',
]
compiled = [re.compile(p, re.I) for p in patterns]
skip_dirs = {'.git', 'python-tools', 'node_modules', '__pycache__'}
findings = []
checked = []
binary = 0
for path in root.rglob('*'):
    rel = path.relative_to(root)
    if not path.is_file() or any(p in skip_dirs or p.startswith('edge-profile-') for p in rel.parts):
        continue
    if path.name == 'TEXT-AUDIT.json':
        continue
    if path.suffix.lower() == '.pdf':
        with pymupdf.open(path) as doc:
            text = '\n'.join(p.get_text() for p in doc)
    else:
        data = path.read_bytes()
        if b'\x00' in data[:4096] and not data.startswith((b'\xff\xfe', b'\xfe\xff')):
            binary += 1
            continue
        try:
            text = data.decode('utf-16' if data.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8-sig')
        except UnicodeError:
            binary += 1
            continue
    checked.append(str(rel))
    for line_number, line in enumerate(text.splitlines(), 1):
        if any(pattern.search(line) for pattern in compiled):
            findings.append({'file': str(rel), 'line': line_number})
report = {'scope': 'Current owned repository files and generated artifacts; published history unchanged',
          'excluded': sorted(skip_dirs) + ['edge-profile-*'], 'checked': checked,
          'binary_files_skipped': binary, 'production_statement_findings': findings,
          'note': 'Pattern scan plus editorial review; not a claim of unaided authorship.'}
(root / 'artifacts/submission/TEXT-AUDIT.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
print(f'Text audit: {len(checked)} files, {len(findings)} production-statement findings')
sys.exit(bool(findings))
