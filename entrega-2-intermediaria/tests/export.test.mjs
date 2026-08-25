import test from "node:test";
import assert from "node:assert/strict";

import { makeExportPayload } from "../web/export.mjs";

test("makeExportPayload serializa participantes e despesas", () => {
  const json = makeExportPayload({
    people: ["Ana", "Beto"],
    expenses: [
      { description: "Mercado", amount: 20, payer: "Ana" }
    ]
  });

  const parsed = JSON.parse(json);

  assert.deepEqual(parsed.people, ["Ana", "Beto"]);
  assert.equal(parsed.expenses.length, 1);
  assert.ok(parsed.exportedAt);
});

test("makeExportPayload rejeita estado invalido", () => {
  assert.throws(() => makeExportPayload(null), TypeError);
});