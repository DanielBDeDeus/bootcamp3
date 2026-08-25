import test from "node:test";
import assert from "node:assert/strict";

import { splitExpense } from "../web/finance.mjs";

test("splitExpense rejeita zero participantes", () => {
  assert.throws(() => splitExpense(100, 0), RangeError);
});

test("splitExpense rejeita quantidade fracionária", () => {
  assert.throws(() => splitExpense(100, 2.5), RangeError);
});