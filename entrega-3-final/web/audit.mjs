export function appendAuditEvent(history, event, now = new Date()) {
  if (!Array.isArray(history)) {
    throw new TypeError("Historico precisa ser um array.");
  }

  if (!event || typeof event.type !== "string" || !event.type.trim()) {
    throw new TypeError("Evento precisa ter type.");
  }

  return [
    ...history,
    {
      timestamp: now.toISOString(),
      type: event.type.trim(),
      detail: event.detail ?? null
    }
  ];
}
