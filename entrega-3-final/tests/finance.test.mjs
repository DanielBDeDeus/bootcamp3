import test from "node:test";
import assert from "node:assert/strict";

import {
  parseAmount,
  splitExpense,
  calculateBalances,
  buildSettlement
} from "../web/finance.mjs";

test("parseAmount aceita virgula", () => {
  assert.equal(parseAmount("12,34"), 12.34);
});

test("splitExpense preserva centavos", () => {
  assert.deepEqual(splitExpense(10, 3), [3.34, 3.33, 3.33]);
});

test("splitExpense rejeita zero", () => {
  assert.throws(() => splitExpense(10, 0), RangeError);
});

test("calculateBalances calcula saldo correto", () => {
  assert.deepEqual(
    calculateBalances(
      ["Ana", "Beto"],
      [{ description: "Mercado", amount: 100, payer: "Ana" }]
    ),
    { Ana: 50, Beto: -50 }
  );
});

test("calculateBalances rejeita duplicados", () => {
  assert.throws(() => calculateBalances(["Ana", "Ana"], []), /duplicados/);
});

test("buildSettlement gera transferencia", () => {
  assert.deepEqual(
    buildSettlement({ Ana: 50, Beto: -50 }),
    [{ from: "Beto", to: "Ana", amount: 50 }]
  );
});
