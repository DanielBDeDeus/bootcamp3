"""Validate actual PDF content/layout; requires PyMuPDF (pymupdf)."""
import json
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root / 'artifacts/python-tools'))
import pymupdf

out = root / 'artifacts/submission'
results = []
for number in (1, 2, 3):
    pdf = out / f'BOOTCAMP3-ENTREGA{number}-DANIEL-BARROS-DE-DEUS.pdf'
    assert pdf.is_file() and pdf.stat().st_size > 10_000, pdf
    with pymupdf.open(pdf) as doc:
        text = '\n'.join(page.get_text() for page in doc)
        assert len(doc) >= 2 and len(text) > 1000
        for expected in ('22600468', 'Daniel Barros de Deus', 'Disciplina', 'Atividade', 'Repositorio', '# pass 10', '# fail 0'):
            assert expected in text, (pdf.name, expected)
        for bad in ('\ufffd', '\u00c2\u00b7', '<html', '<div', '\u00e2\u20ac'):
            assert bad not in text, (pdf.name, bad)
        for index, page in enumerate(doc):
            assert abs(page.rect.width - 612) < 1 and abs(page.rect.height - 792) < 1
            assert f'Pagina {index + 1} de {len(doc)}' in page.get_text()
            assert len(page.get_text().strip()) > 100, (pdf.name, index, 'near-empty page')
            page.get_pixmap(matrix=pymupdf.Matrix(1, 1)).save(out / f'preview-e{number}-p{index + 1}.png')
        results.append({'file': pdf.name, 'bytes': pdf.stat().st_size, 'pages': len(doc), 'format': 'US Letter', 'text_and_numbering': 'PASS'})
(out / 'PDF-VALIDATION.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
print(json.dumps(results, indent=2))
