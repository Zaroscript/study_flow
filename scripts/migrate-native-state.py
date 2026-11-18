from pathlib import Path

header='''import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/homework_model.dart';
import '../../../data/models/goal_model.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/stats_model.dart';
import '../../../data/models/pomodoro_settings.dart';
import '../../../data/local/preferences/preferences_service.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/local/database/sqlite_database.dart';
import '../../../data/repositories/study_flow_repository.dart';
import '../../../data/repositories/drift_study_flow_repository.dart';
import 'persistent_notifier.dart';

final preferencesServiceProvider = Provider<IPreferencesService>((ref) => throw StateError('Preferences must be initialized in bootstrap'));
final appDatabaseProvider = Provider<IAppDatabase>((ref) { final database = EnoteDatabase(); ref.onDispose(() { database.close(); }); return database; });
final studyFlowRepositoryProvider = Provider<IStudyFlowRepository>((ref) => DriftStudyFlowRepository(ref.watch(appDatabaseProvider)));
'''
header+='''
final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) => ProfileNotifier(ref.watch(studyFlowRepositoryProvider)));
class ProfileNotifier extends PersistentNotifier<UserProfile?> {
  final IStudyFlowRepository _repo;
  ProfileNotifier(this._repo): super(null, _repo.getProfile);
  Future<void> saveProfile(UserProfile p) => change((_) async { await _repo.saveProfile(p); return p; });
  Future<void> clearProfile() => change((_) async { await _repo.clearProfile(); return null; });
}
'''
for name,model,getter,add,delete in [('Tasks','TaskModel','getTasks','addTask','deleteTask'),('Homework','HomeworkModel','getHomework','addHomework','deleteHomework'),('Goals','GoalModel','getGoals','addGoal','deleteGoal'),('Habits','HabitModel','getHabits','addHabit','deleteHabit'),('Notes','NoteModel','getNotes','addNote','deleteNote')]:
    provider=name.lower()+'Provider'; c=name+'Notifier'
    header+=f'''\nfinal {provider} = StateNotifierProvider<{c}, List<{model}>>((ref) => {c}(ref.watch(studyFlowRepositoryProvider)));
class {c} extends PersistentNotifier<List<{model}>> {{
  final IStudyFlowRepository _repo;
  {c}(this._repo): super(const [], _repo.{getter});
  Future<void> {add}({model} item) => change((current) async {{ await _repo.{add}(item); return [...current.where((x)=>x.id!=item.id), item]; }});
  Future<void> {delete}(String id) => change((current) async {{ await _repo.{delete}(id); return current.where((x)=>x.id!=id).toList(); }});
'''
    if name=='Tasks': header+='''  Future<void> toggleTaskCompletion(String id) => change((current) async { final next = <TaskModel>[]; for (final task in current) { if (task.id==id) { final updated=task.copyWith(completed: !task.completed); await _repo.updateTask(updated); next.add(updated); } else { next.add(task); } } return next; });\n'''
    if name=='Homework': header+='''  Future<void> toggleStatus(String id) => change((current) async { final next=<HomeworkModel>[]; for (final item in current) { if (item.id==id) { final updated=item.copyWith(status: item.status=='completed'?'pending':'completed'); await _repo.updateHomework(updated); next.add(updated); } else { next.add(item); } } return next; });\n'''
    if name=='Goals': header+='''  Future<void> incrementGoal(String id) => change((current) async { final next=<GoalModel>[]; for(final goal in current) { if(goal.id==id) { final updated=goal.copyWith(current:(goal.current+1).clamp(0,goal.target)); await _repo.updateGoal(updated); next.add(updated); } else { next.add(goal); } } return next; });\n'''
    if name=='Habits': header+='''  Future<void> toggleHabit(String id, String day) => change((current) async { final next=<HabitModel>[]; for(final habit in current) { if(habit.id==id) { final updated=habit.copyWith(history:{...habit.history,day:!(habit.history[day]??false)}); await _repo.updateHabit(updated); next.add(updated); } else { next.add(habit); } } return next; });\n'''
    if name=='Notes': header+='''  Future<void> updateNote(NoteModel item) => change((current) async { await _repo.addNote(item); return current.map((x)=>x.id==item.id?item:x).toList(); });\n'''
    header+='}\n'
header+='''
final statsProvider = StateNotifierProvider<StatsNotifier,StudyStats>((ref)=>StatsNotifier(ref.watch(studyFlowRepositoryProvider)));
class StatsNotifier extends PersistentNotifier<StudyStats> {
  final IStudyFlowRepository _repo;
  StatsNotifier(this._repo):super(const StudyStats(focusScore:0),_repo.getStats);
  Future<void> addStudyMinutes(int minutes)=>change((current)async{if(minutes<0)throw ArgumentError('Invalid minutes');final next=current.copyWith(studyTimeMinutes:current.studyTimeMinutes+minutes);await _repo.updateStats(next);return next;});
}
final pomodoroSettingsProvider=StateNotifierProvider<PomodoroSettingsNotifier,PomodoroSettings>((ref)=>PomodoroSettingsNotifier(ref.watch(studyFlowRepositoryProvider)));
class PomodoroSettingsNotifier extends PersistentNotifier<PomodoroSettings>{
  final IStudyFlowRepository _repo;
  PomodoroSettingsNotifier(this._repo):super(const PomodoroSettings(),_repo.getPomodoroSettings);
  Future<void> updateSettings(PomodoroSettings settings)=>change((_)async{if(settings.study<1||settings.study>120||settings.breakDuration<1||settings.breakDuration>30||settings.longBreak<1||settings.longBreak>60)throw ArgumentError('Invalid timer durations');await _repo.updatePomodoroSettings(settings);return settings;});
}
'''
Path('lib/features/common/providers/study_flow_state_provider.dart').write_text(header,encoding='utf8')
p=Path('lib/features/ai_assistant/services/ai_assistant_service.dart');s=p.read_text(encoding='utf8');a=s.index("    if (lower.contains('قلق')");b=s.index('    // Default intelligent',a);block=s[a:b];s=s[:a]+s[b:];at=s.index('    // 2. Quiz');s=s[:at]+block+'\n'+s[at:];p.write_text(s,encoding='utf8')
p=Path('lib/features/ai_assistant/providers/ai_assistant_provider.dart');s=p.read_text(encoding='utf8');import re;s=re.sub(r'(await Future.delayed\([^;]+;)',r'\1\n    if (!mounted) return;',s);s=s.replace('مساعدك الدراسي الذكي في StudyFlow','مساعدك الدراسي المحلي في ENote');p.write_text(s,encoding='utf8')
p=Path('lib/features/pomodoro/screens/pomodoro_screen.dart');s=p.read_text(encoding='utf8').replace('await PomodoroAlarmService.triggerAlarm(_alarmSettings);','await PomodoroAlarmService.triggerAlarm(_alarmSettings);\n    if (!mounted) return;').replace('    ref.read(notificationServiceProvider).triggerPomodoroFinishNotification(', '    await ref.read(notificationServiceProvider).triggerPomodoroFinishNotification(').replace('      ref.read(statsProvider.notifier).addStudyMinutes(settings.study);','      await ref.read(statsProvider.notifier).addStudyMinutes(settings.study);\n      if (!mounted) return;');p.write_text(s,encoding='utf8')

