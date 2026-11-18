/** Validate persisted user data without silently overwriting the original. */
export function decodeWorkspace(raw: string, defaults: Record<string, any>) {
  const parsed = JSON.parse(raw);
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error('Invalid workspace');
  const result = { ...defaults, ...parsed };
  const string = (value: unknown) => typeof value === 'string';
  const finite = (value: unknown) => typeof value === 'number' && Number.isFinite(value);
  const validators: Record<string, (value: any) => boolean> = {
    tasks: x => string(x.id) && string(x.title) && string(x.category) && string(x.date) && string(x.startTime) && string(x.endTime) && typeof x.completed === 'boolean',
    homework: x => string(x.id) && string(x.subject) && string(x.description) && string(x.deadline) && string(x.status),
    goals: x => string(x.id) && string(x.title) && finite(x.target) && x.target > 0 && finite(x.current) && x.current >= 0 && x.current <= x.target,
    habits: x => string(x.id) && string(x.name) && x.history && typeof x.history === 'object' && !Array.isArray(x.history),
    notes: x => string(x.id) && string(x.title) && string(x.content) && string(x.folder) && string(x.date),
    exams: x => string(x.id) && string(x.subject) && string(x.date),
    materialsFolders: x => string(x.id) && string(x.name),
    materialsItems: x => string(x.id) && string(x.title) && string(x.folderId) && finite(x.totalPages) && finite(x.readPages),
    schedule: x => Number.isInteger(x.day) && Array.isArray(x.lessons),
  };
  for (const [key, valid] of Object.entries(validators)) {
    if (!Array.isArray(result[key]) || result[key].some((x: any) => !x || !valid(x))) throw new Error(`Invalid ${key}`);
  }
  if (result.profile !== null && (!result.profile || !string(result.profile.name) || !string(result.profile.grade))) throw new Error('Invalid profile');
  if (!result.stats || !finite(result.stats.studyTimeMinutes) || !finite(result.stats.tasksCompleted) || !finite(result.stats.focusScore)) throw new Error('Invalid statistics');
  return result;
}
