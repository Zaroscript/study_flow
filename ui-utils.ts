export function localDateKey(date = new Date()) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}

export function validGoal(goal: { title: string; target: unknown; current: unknown }) {
  const target = Number(goal.target), current = Number(goal.current);
  return goal.title.trim().length > 0 && goal.target !== '' && goal.current !== '' && Number.isFinite(target) && Number.isFinite(current) && target > 0 && current >= 0 && current <= target;
}

export function validTimer(settings: { study: unknown; break: unknown; longBreak: unknown }) {
  return Object.entries({ study: 120, break: 30, longBreak: 60 }).every(([key, max]) => {
    const value = Number(settings[key]);
    return Number.isInteger(value) && value >= 1 && value <= max;
  });
}

export function scheduledMinutes(task: { startTime: string; endTime: string }) {
  const minutes = (time: string) => /^(?:[01]\d|2[0-3]):[0-5]\d$/.test(time) ? Number(time.slice(0, 2)) * 60 + Number(time.slice(3)) : NaN;
  const start = minutes(task.startTime), end = minutes(task.endTime);
  return Number.isFinite(start) && Number.isFinite(end) && end > start && end <= 1440 ? end - start : 0;
}
