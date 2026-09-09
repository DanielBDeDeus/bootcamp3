export function createExportData(state, now = new Date()) {
  if (!state || !Array.isArray(state.people) || !Array.isArray(state.expenses)) {
    throw new TypeError("Estado invalido.");
  }

  return {
    schemaVersion: 1,
    exportedAt: now.toISOString(),
    people: [...state.people],
    expenses: state.expenses.map(expense => ({ ...expense }))
  };
}
