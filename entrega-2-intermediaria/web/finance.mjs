export function parseAmount(value) {
  const normalized = String(value).trim().replace(",", ".");
  const amount = Number(normalized);

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new RangeError("O valor deve ser um número positivo.");
  }

  return Math.round(amount * 100) / 100;
}

export function splitExpense(amount, participantCount) {
  if (!Number.isInteger(participantCount) || participantCount <= 0) {
    throw new RangeError("A quantidade de participantes deve ser um inteiro maior que zero.");
  }

  const cents = Math.round(parseAmount(amount) * 100);
  const base = Math.floor(cents / participantCount);
  const remainder = cents % participantCount;

  return Array.from({ length: participantCount }, (_, index) =>
    (base + (index < remainder ? 1 : 0)) / 100
  );
}

export function calculateBalances(people, expenses) {
  if (!Array.isArray(people) || people.length === 0) {
    throw new RangeError("Informe pelo menos um participante.");
  }

  const cleanPeople = people.map(name => String(name).trim());

  if (cleanPeople.some(name => !name)) {
    throw new Error("Os participantes precisam ter nome.");
  }

  const balances = Object.fromEntries(cleanPeople.map(name => [name, 0]));

  for (const expense of expenses) {
    const amount = parseAmount(expense.amount);

    if (!Object.hasOwn(balances, expense.payer)) {
      throw new Error("Pagador não pertence à lista de participantes.");
    }

    const shares = splitExpense(amount, cleanPeople.length);
    balances[expense.payer] += amount;

    cleanPeople.forEach((person, index) => {
      balances[person] -= shares[index];
    });
  }

  for (const person of cleanPeople) {
    balances[person] = Math.round(balances[person] * 100) / 100;
  }

  return balances;
}