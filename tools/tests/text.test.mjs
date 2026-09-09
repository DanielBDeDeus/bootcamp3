import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
for (const file of ['README.md', 'entrega-2-intermediaria/README.md', 'entrega-2-intermediaria/docs/ERROS-E-REESPECIFICACAO.md', 'tools/bootcamp3-super.ps1']) {
  test(`UTF-8 without mojibake: ${file}`, () => {
    const text = readFileSync(new URL(`../../${file}`, import.meta.url), 'utf8');
    assert.doesNotMatch(text, /\u00c3[\u0080-\u00bf\u0192]|\u00c2[\u0080-\u00bf]|\u00e2\u20ac|\ufffd/);
  });
}
