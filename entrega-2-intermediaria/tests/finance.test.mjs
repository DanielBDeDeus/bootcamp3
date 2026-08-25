import test from "node:test";
import assert from "node:assert/strict";

import {
  parseAmount,
  splitExpense,
  calculateBalances
} from "../web/finance.mjs";

test("parseAmount aceita vírgula decimal", () => {
  assert.equal(parseAmount("10,50"), 10.5);
});

test("parseAmount rejeita zero", () => {
  assert.throws(() => parseAmount("0"), RangeError);
});

test("parseAmount rejeita texto", () => {
  assert.throws(() => parseAmount("abc"), RangeError);
});

test("splitExpense divide valor exato", () => {
  assert.deepEqual(splitExpense(90, 3), [30, 30, 30]);
});

test("splitExpense preserva os centavos", () => {
  const shares = splitExpense(100, 3);
  assert.equal(shares.reduce((sum, value) => sum + value, 0), 100);
});

test("calculateBalances mantém soma final igual a zero", () => {
  const balances = calculateBalances(
    ["Ana", "Beto"],
    [{ description: "Mercado", amount: 100, payer: "Ana" }]
  );

  assert.equal(balances.Ana, 50);
  assert.equal(balances.Beto, -50);
  assert.equal(balances.Ana + balances.Beto, 0);
});