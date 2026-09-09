import test from "node:test";
import assert from "node:assert/strict";
import { createExportData } from "../web/export.mjs";

test("exportacao inclui schema, participantes e despesas", () => {
  const now = new Date("2026-09-09T12:00:00Z");
  const data = createExportData(
    {
      people: ["Ana", "Beto"],
      expenses: [{ description: "Cafe", amount: 10, payer: "Ana" }]
    },
    now
  );

  assert.equal(data.schemaVersion, 1);
  assert.equal(data.exportedAt, "2026-09-09T12:00:00.000Z");
  assert.deepEqual(data.people, ["Ana", "Beto"]);
  assert.equal(data.expenses.length, 1);
});

test("exportacao rejeita estado invalido", () => {
  assert.throws(() => createExportData({}), TypeError);
});
