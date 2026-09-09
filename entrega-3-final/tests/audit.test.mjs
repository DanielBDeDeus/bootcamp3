import test from "node:test";
import assert from "node:assert/strict";
import { appendAuditEvent } from "../web/audit.mjs";

test("auditoria adiciona timestamp e tipo", () => {
  const result = appendAuditEvent(
    [],
    { type: "expense.added", detail: "Mercado" },
    new Date("2026-09-09T12:00:00Z")
  );

  assert.deepEqual(result, [{
    timestamp: "2026-09-09T12:00:00.000Z",
    type: "expense.added",
    detail: "Mercado"
  }]);
});

test("auditoria rejeita evento sem tipo", () => {
  assert.throws(() => appendAuditEvent([], {}), TypeError);
});
