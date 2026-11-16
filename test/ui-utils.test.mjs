import test from 'node:test';
import assert from 'node:assert/strict';
import { localDateKey, scheduledMinutes, validGoal, validTimer } from '../ui-utils.ts';

test('calendar keys use the local day, including midnight and year boundaries', () => {
  assert.equal(localDateKey(new Date(2026, 0, 1, 0, 15)), '2026-01-01');
  assert.equal(localDateKey(new Date(2026, 11, 31, 23, 45)), '2026-12-31');
});
test('goal validation rejects zero, nonfinite, blank and contradictory progress', () => {
  assert.equal(validGoal({title:'Study',target:10,current:3}),true);
  for (const goal of [{title:' ',target:10,current:0},{title:'x',target:0,current:0},{title:'x',target:5,current:6},{title:'x',target:Infinity,current:0},{title:'x',target:'',current:0},{title:'x',target:10,current:-1}]) assert.equal(validGoal(goal),false);
});
test('timer durations stay within each mode’s supported range', () => {
  assert.equal(validTimer({study:25,break:5,longBreak:15}),true);
  assert.equal(validTimer({study:0,break:5,longBreak:15}),false);
  assert.equal(validTimer({study:25,break:31,longBreak:15}),false);
  assert.equal(validTimer({study:25,break:5,longBreak:61}),false);
  assert.equal(validTimer({study:2.5,break:5,longBreak:15}),false);
});
test('planned minutes reject reversed/malformed time ranges', () => {
  assert.equal(scheduledMinutes({startTime:'09:00',endTime:'10:30'}),90);
  assert.equal(scheduledMinutes({startTime:'10:30',endTime:'09:00'}),0);
  assert.equal(scheduledMinutes({startTime:'10:30',endTime:'10:30'}),0);
  assert.equal(scheduledMinutes({startTime:'',endTime:'11:00'}),0);
  assert.equal(scheduledMinutes({startTime:'12:99',endTime:'14:00'}),0);
  assert.equal(scheduledMinutes({startTime:'23:30',endTime:'24:00'}),0);
});
