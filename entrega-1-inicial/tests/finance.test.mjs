import test from "node:test";
import assert from "node:assert/strict";

import {
  parseAmount,
  splitExpense,
  calculateBalances
} from "../src/finance.mjs";

test("RF-01: aceita virgula decimal", () => {
  assert.equal(parseAmount("10,50"), 10.5);
});

test("RF-01: rejeita zero", () => {
  assert.throws(() => parseAmount("0"), RangeError);
});

test("RF-02: divide valor exato", () => {
  assert.deepEqual(splitExpense(90, 3), [30, 30, 30]);
});

test("RF-02: preserva todos os centavos", () => {
  assert.deepEqual(splitExpense(100, 3), [33.34, 33.33, 33.33]);
});

test("RF-03: rejeita zero participantes", () => {
  assert.throws(() => splitExpense(100, 0), RangeError);
});

test("RF-03: rejeita quantidade fracionaria", () => {
  assert.throws(() => splitExpense(100, 1.5), RangeError);
});

test("RF-04: saldo final soma zero", () => {
  const balances = calculateBalances(
    ["Ana", "Beto"],
    [{ description: "Mercado", amount: 100, payer: "Ana" }]
  );
  assert.deepEqual(balances, { Ana: 50, Beto: -50 });
});

test("RF-05: rejeita pagador inexistente", () => {
  assert.throws(
    () => calculateBalances(
      ["Ana", "Beto"],
      [{ description: "Mercado", amount: 100, payer: "Carlos" }]
    ),
    /Pagador/
  );
});

test("RF-06: rejeita nome vazio", () => {
  assert.throws(() => calculateBalances(["Ana", " "], []), /nome/);
});

test("RF-06: rejeita duplicado", () => {
  assert.throws(() => calculateBalances(["Ana", "Ana"], []), /unicos/);
});
