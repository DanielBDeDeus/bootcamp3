import { calculateBalances, buildSettlement, parseAmount } from "./finance.mjs";
import { createExportData } from "./export.mjs";
import { appendAuditEvent } from "./audit.mjs";

const $ = selector => document.querySelector(selector);

const STORAGE_KEY = "dividimos-lite-v1";

let state = loadState();
let audit = [];

function loadState() {
  try {
    const parsed = JSON.parse(localStorage.getItem(STORAGE_KEY) || "null");
    if (parsed && Array.isArray(parsed.people) && Array.isArray(parsed.expenses)) {
      return parsed;
    }
  } catch {}
  return { people: ["Pessoa A", "Pessoa B"], expenses: [] };
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function money(value) {
  return value.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
}

function render() {
  $("#personA").value = state.people[0] ?? "";
  $("#personB").value = state.people[1] ?? "";

  const expenses = $("#expenses");
  expenses.innerHTML = "";

  for (const [index, expense] of state.expenses.entries()) {
    const li = document.createElement("li");
    li.textContent = `${expense.description}: ${money(expense.amount)} - pago por ${expense.payer}`;

    const remove = document.createElement("button");
    remove.textContent = "Remover";
    remove.addEventListener("click", () => {
      state.expenses.splice(index, 1);
      audit = appendAuditEvent(audit, { type: "expense.removed", detail: expense.description });
      saveState();
      render();
    });

    li.append(" ", remove);
    expenses.appendChild(li);
  }

  const result = $("#result");
  try {
    const balances = calculateBalances(state.people, state.expenses);
    const settlement = buildSettlement(balances);

    result.innerHTML = `
      <h3>Saldos</h3>
      ${Object.entries(balances).map(([name, value]) => `<p>${name}: <strong>${money(value)}</strong></p>`).join("")}
      <h3>Acerto sugerido</h3>
      ${settlement.length
        ? settlement.map(item => `<p>${item.from} paga ${money(item.amount)} para ${item.to}</p>`).join("")
        : "<p>Nada a acertar.</p>"
      }
    `;
  } catch (error) {
    result.textContent = error.message;
  }
}

$("#peopleForm").addEventListener("submit", event => {
  event.preventDefault();
  state.people = [$("#personA").value.trim(), $("#personB").value.trim()];
  audit = appendAuditEvent(audit, { type: "people.updated" });
  saveState();
  render();
});

$("#expenseForm").addEventListener("submit", event => {
  event.preventDefault();

  const description = $("#description").value.trim();
  const amount = parseAmount($("#amount").value);
  const payer = $("#payer").value === "A" ? state.people[0] : state.people[1];

  state.expenses.push({ description, amount, payer });
  audit = appendAuditEvent(audit, { type: "expense.added", detail: description });
  saveState();
  event.target.reset();
  render();
});

$("#exportButton").addEventListener("click", () => {
  const data = createExportData(state);
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = "dividimos-export.json";
  anchor.click();
  URL.revokeObjectURL(url);
});

$("#resetButton").addEventListener("click", () => {
  state = { people: ["Pessoa A", "Pessoa B"], expenses: [] };
  audit = appendAuditEvent(audit, { type: "state.reset" });
  saveState();
  render();
});

render();
