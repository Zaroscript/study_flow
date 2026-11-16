import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/shell/app_shell.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/planner/screens/planner_screen.dart';
import '../../features/pomodoro/screens/pomodoro_screen.dart';
import '../../features/homework/screens/homework_screen.dart';
import '../../features/goals/screens/goals_screen.dart';
import '../../features/habits/screens/habits_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/statistics/screens/statistics_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/materials/screens/materials_screen.dart';
import '../../features/materials/screens/subject_detail_screen.dart';
import '../../features/rewards/screens/rewards_screen.dart';
import '../../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/common/providers/study_flow_state_provider.dart';
import '../../data/models/material_item_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(profileProvider, (_, __) => refresh.value++);
  final prefs = ref.watch(preferencesServiceProvider);

  final router = GoRouter(
    refreshListenable: refresh,
    initialLocation: '/dashboard',
    redirect: (BuildContext context, GoRouterState state) {
      final isOnboarding = state.matchedLocation == '/onboarding';
      final profile = ref.read(profileProvider);
      final hasCompleted = prefs.isOnboardingCompleted() || profile != null;

      // If user hasn't completed onboarding and isn't on onboarding, redirect
      if (!hasCompleted && !isOnboarding) {
        return '/onboarding';
      }

      // If user has completed onboarding and attempts to visit onboarding, redirect to dashboard
      if (hasCompleted && isOnboarding) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/materials/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final folder = state.extra as MaterialFolder?;
          return SubjectDetailScreen(folderId: id, folder: folder);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(location: state.uri.path, child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner',
                builder: (context, state) => const PlannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pomodoro',
                builder: (context, state) => const PomodoroScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/homework',
                builder: (context, state) => const HomeworkScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/materials',
                builder: (context, state) => const MaterialsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                builder: (context, state) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/goals',
                builder: (context, state) => const GoalsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => const NotesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                redirect: (context, state) => '/dashboard',
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai-assistant',
                builder: (context, state) => const AiAssistantScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
