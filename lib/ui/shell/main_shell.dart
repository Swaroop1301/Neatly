import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'widgets/glass_nav_bar.dart';
import 'widgets/upload_fab.dart';
import '../../providers/documents_provider.dart';
import '../../providers/settings_provider.dart';

import 'package:go_router/go_router.dart';

/// Main app shell with floating glass nav bar and screen switching.
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/library')) return 1;
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/library');
        break;
      case 2:
        context.go('/search');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // Set system UI for edge-to-edge
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _showUploadSheet() {
    ref.read(documentsProvider.notifier).pickAndUploadFiles(multiple: true);
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(settingsProvider).accentColor;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      body: widget.child,
      // Using a Stack for the floating nav bar + FAB
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GlassNavBar(
              currentIndex: currentIndex,
              onTabSelected: (index) => _onItemTapped(index, context),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: UploadFab(
          accent: accent,
          onTap: _showUploadSheet,
        ),
      ),
    );
  }

}
