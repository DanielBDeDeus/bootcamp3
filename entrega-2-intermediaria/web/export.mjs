export function makeExportPayload(state) {
  if (!state || !Array.isArray(state.people) || !Array.isArray(state.expenses)) {
    throw new TypeError("Estado inválido para exportação.");
  }

  return JSON.stringify({
    exportedAt: new Date().toISOString(),
    people: state.people,
    expenses: state.expenses
  }, null, 2);
}