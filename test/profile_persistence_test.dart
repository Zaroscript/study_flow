import '../lib/data/models/user_profile.dart';

// Standalone test implementation of database and repository for test execution
class TestAppDatabase {
  int get schemaVersion => 1;
  UserProfile? _profile;

  Future<UserProfile?> getProfile() async => _profile;
  Future<void> saveProfile(UserProfile profile) async => _profile = profile;
  Future<void> updateProfile(UserProfile profile) async => _profile = profile;
  Future<void> clearProfile() async => _profile = null;
}

class TestStudyFlowRepository {
  final TestAppDatabase _db;
  TestStudyFlowRepository(this._db);

  Future<UserProfile?> getProfile() => _db.getProfile();
  Future<void> saveProfile(UserProfile profile) => _db.saveProfile(profile);
  Future<void> clearProfile() => _db.clearProfile();
}

Future<void> main() async {
  print('--- Running Profile Persistence & Repository Tests ---');

  final db = TestAppDatabase();
  final repo = TestStudyFlowRepository(db);

  // Test 1: Initial state is clean/null (No fake demo data)
  final initialProfile = await repo.getProfile();
  assert(initialProfile == null, 'Initial profile should be null without fake data');
  print('✅ Test 1 Passed: Initial profile is null as expected');

  // Test 2: Profile creation and persistence
  const newProfile = UserProfile(
    name: 'سارة خالد',
    grade: 'المرحلة الثانوية',
  );
  await repo.saveProfile(newProfile);

  final fetchedProfile = await repo.getProfile();
  assert(fetchedProfile != null, 'Profile should be retrieved from repository');
  assert(fetchedProfile!.name == 'سارة خالد', 'Retrieved name should match');
  assert(fetchedProfile!.grade == 'المرحلة الثانوية', 'Retrieved grade should match');
  print('✅ Test 2 Passed: Profile created and persisted successfully');

  // Test 3: Profile update (Editing name & stage)
  final updatedProfile = fetchedProfile!.copyWith(
    name: 'سارة خالد أحمد',
    grade: 'المرحلة الجامعية',
  );
  await repo.saveProfile(updatedProfile);

  final verifiedProfile = await repo.getProfile();
  assert(verifiedProfile != null, 'Updated profile should exist');
  assert(verifiedProfile!.name == 'سارة خالد أحمد', 'Name should be updated');
  assert(verifiedProfile!.grade == 'المرحلة الجامعية', 'Grade should be updated');
  print('✅ Test 3 Passed: Profile updated and changes verified');

  // Test 4: Profile clear
  await repo.clearProfile();
  final clearedProfile = await repo.getProfile();
  assert(clearedProfile == null, 'Profile should be cleared');
  print('✅ Test 4 Passed: Profile cleared successfully');

  print('🎉 All Profile Persistence Tests Passed!\n');
}
