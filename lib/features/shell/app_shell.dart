import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/providers/theme_provider.dart';
import '../notifications/providers/notifications_provider.dart';
import '../notifications/screens/notifications_screen.dart';
import 'app_drawer.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  final String location;
  const AppShell({super.key, required this.child, required this.location});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static const _routes = ['/dashboard', '/planner', '/pomodoro', '/materials'];
  int get _selectedIndex {
    final index = _routes.indexWhere(widget.location.startsWith);
    return index < 0 ? 4 : index;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final expanded = constraints.maxWidth >= 900;
      final dark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        key: _scaffoldKey,
        drawer: expanded ? null : AppDrawer(currentRoute: widget.location),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: MediaQuery.textScalerOf(context).scale(20) > 26
              ? 80
              : 64,
          leading: expanded
              ? null
              : IconButton(
                  tooltip: 'فتح القائمة',
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'public/assets/enote-icon.png',
                  width: 36,
                  height: 36,
                  cacheWidth: 72,
                  cacheHeight: 72,
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(width: 12),
              const Text('ENote'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'مركز الإشعارات',
              icon: Badge(
                isLabelVisible: ref.watch(unreadNotificationsCountProvider) > 0,
                label: Text(
                  '${ref.watch(unreadNotificationsCountProvider)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => showNotificationsModal(context),
            ),
            IconButton(
              tooltip: dark ? 'تفعيل المظهر الفاتح' : 'تفعيل المظهر الداكن',
              icon: Icon(
                dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () =>
                  ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: expanded,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (expanded) ...[
                SizedBox(
                  width: 268,
                  child: AppDrawer(
                    currentRoute: widget.location,
                    persistent: true,
                  ),
                ),
                const VerticalDivider(width: 1),
              ],
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: expanded
            ? null
            : NavigationBar(
                selectedIndex: _selectedIndex,
                labelBehavior: MediaQuery.textScalerOf(context).scale(12) > 18
                    ? NavigationDestinationLabelBehavior.onlyShowSelected
                    : NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (index) {
                  if (index == 4) {
                    _scaffoldKey.currentState?.openDrawer();
                  } else {
                    context.go(_routes[index]);
                  }
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'الرئيسية',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    label: 'المخطط',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.timer_outlined),
                    label: 'التركيز',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.folder_outlined),
                    label: 'المكتبة',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_rounded),
                    label: 'المزيد',
                  ),
                ],
              ),
      );
    },
  );
}
