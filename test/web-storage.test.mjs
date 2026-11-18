import test from 'node:test';
import assert from 'node:assert/strict';
import {decodeWorkspace} from '../web-storage.ts';
const defaults={profile:null,tasks:[],homework:[],goals:[],habits:[],notes:[],exams:[],materialsFolders:[],materialsItems:[],schedule:[],stats:{studyTimeMinutes:0,tasksCompleted:0,focusScore:0}};
test('corrupt collections are rejected without mutating the original',()=>{
  const raw=JSON.stringify({profile:{name:'Student',grade:'Other'},tasks:null});
  assert.throws(()=>decodeWorkspace(raw,defaults));
  assert.equal(JSON.parse(raw).tasks,null);assert.deepEqual(defaults.tasks,[]);
});
test('older workspaces gain missing collections and retain user text',()=>{
  const raw=JSON.stringify({profile:{name:'العربية English',grade:'Other'}});
  assert.equal(decodeWorkspace(raw,defaults).profile.name,'العربية English');
});
