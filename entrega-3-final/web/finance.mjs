export function parseAmount(value) {
  const normalized = String(value).trim().replace(",", ".");
  const amount = Number(normalized);

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new RangeError("Valor deve ser positivo.");
  }

  return Math.round(amount * 100) / 100;
}

export function splitExpense(amount, participantCount) {
  if (!Number.isInteger(participantCount) || participantCount <= 0) {
    throw new RangeError("Quantidade de participantes deve ser inteiro maior que zero.");
  }

  const cents = Math.round(parseAmount(amount) * 100);
  const base = Math.floor(cents / participantCount);
  const remainder = cents % participantCount;

  return Array.from({ length: participantCount }, (_, index) =>
    (base + (index < remainder ? 1 : 0)) / 100
  );
}

export function calculateBalances(people, expenses) {
  if (!Array.isArray(people) || people.length < 2) {
    throw new RangeError("Informe ao menos dois participantes.");
  }

  const names = people.map(value => String(value).trim());

  if (names.some(name => !name)) {
    throw new Error("Nome vazio nao e permitido.");
  }

  if (new Set(names).size !== names.length) {
    throw new Error("Nomes duplicados nao sao permitidos.");
  }

  if (!Array.isArray(expenses)) {
    throw new TypeError("Despesas devem ser um array.");
  }

  const balances = Object.fromEntries(names.map(name => [name, 0]));

  for (const expense of expenses) {
    const amount = parseAmount(expense.amount);
    if (!names.includes(expense.payer)) {
      throw new Error("Pagador invalido.");
    }

    const shares = splitExpense(amount, names.length);
    balances[expense.payer] += amount;

    names.forEach((name, index) => {
      balances[name] -= shares[index];
    });
  }

  for (const name of names) {
    balances[name] = Math.round(balances[name] * 100) / 100;
  }

  return balances;
}

export function buildSettlement(balances) {
  const debtors = [];
  const creditors = [];

  for (const [name, value] of Object.entries(balances)) {
    const cents = Math.round(value * 100);
    if (cents < 0) debtors.push({ name, cents: -cents });
    if (cents > 0) creditors.push({ name, cents });
  }

  const transfers = [];
  let d = 0;
  let c = 0;

  while (d < debtors.length && c < creditors.length) {
    const amount = Math.min(debtors[d].cents, creditors[c].cents);

    transfers.push({
      from: debtors[d].name,
      to: creditors[c].name,
      amount: amount / 100
    });

    debtors[d].cents -= amount;
    creditors[c].cents -= amount;

    if (debtors[d].cents === 0) d += 1;
    if (creditors[c].cents === 0) c += 1;
  }

  return transfers;
}
