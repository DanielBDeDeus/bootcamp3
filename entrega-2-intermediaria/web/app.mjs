import { calculateBalances, parseAmount } from "./finance.mjs";

const STORAGE_KEY = "bootcamp3-dividimos-lite";

const els = {
  personA: document.querySelector("#personA"),
  personB: document.querySelector("#personB"),
  form: document.querySelector("#expenseForm"),
  description: document.querySelector("#description"),
  amount: document.querySelector("#amount"),
  payer: document.querySelector("#payer"),
  summary: document.querySelector("#summary"),
  expenses: document.querySelector("#expenses"),
  message: document.querySelector("#message"),
  clearBtn: document.querySelector("#clearBtn")
};

const defaultState = {
  people: ["Pessoa A", "Pessoa B"],
  expenses: []
};

let state = loadState();

function loadState() {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY));
    if (saved && saved.people && saved.people.length === 2 && Array.isArray(saved.expenses)) {
      return saved;
    }
  } catch (error) {}

  return JSON.parse(JSON.stringify(defaultState));
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function syncPeople() {
  state.people = [
    els.personA.value.trim() || "Pessoa A",
    els.personB.value.trim() || "Pessoa B"
  ];
  saveState();
  render();
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function render() {
  els.personA.value = state.people[0];
  els.personB.value = state.people[1];

  els.payer.innerHTML = "";

  for (const person of state.people) {
    const option = document.createElement("option");
    option.value = person;
    option.textContent = person;
    els.payer.append(option);
  }

  const balances = calculateBalances(state.people, state.expenses);

  els.summary.innerHTML = state.people.map(person => {
    const value = balances[person];

    const text = value > 0
      ? `tem a receber R$ ${value.toFixed(2)}`
      : value < 0
        ? `deve R$ ${Math.abs(value).toFixed(2)}`
        : "está quitado";

    return `<div class="balance"><strong>${escapeHtml(person)}</strong>: ${text}</div>`;
  }).join("");

  els.expenses.innerHTML = state.expenses.length
    ? state.expenses.map(expense =>
        `<li>${escapeHtml(expense.description)} — R$ ${expense.amount.toFixed(2)} — pago por ${escapeHtml(expense.payer)}</li>`
      ).join("")
    : "<li>Nenhuma despesa cadastrada.</li>";
}

els.personA.addEventListener("change", syncPeople);
els.personB.addEventListener("change", syncPeople);

els.form.addEventListener("submit", event => {
  event.preventDefault();
  els.message.textContent = "";

  try {
    const amount = parseAmount(els.amount.value);

    state.expenses.push({
      id: String(Date.now()) + Math.random(),
      description: els.description.value.trim(),
      amount: amount,
      payer: els.payer.value
    });

    saveState();
    els.form.reset();
    render();
    els.message.textContent = "Despesa adicionada.";
  }
  catch (error) {
    els.message.textContent = error.message;
  }
});

els.clearBtn.addEventListener("click", () => {
  state = JSON.parse(JSON.stringify(defaultState));
  saveState();
  render();
});

render();