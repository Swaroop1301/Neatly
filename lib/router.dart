import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/screens/home/home_screen.dart';
import 'ui/screens/library/library_screen.dart';
import 'ui/screens/library/folder_detail_screen.dart';
import 'ui/screens/search/search_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'ui/screens/document_detail/document_detail_screen.dart';
import 'ui/shell/main_shell.dart';
import 'domain/models/folder.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    
    if (isFirstLaunch && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    } else if (!isFirstLaunch && state.matchedLocation == '/onboarding') {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const LibraryScreen(),
          routes: [
            GoRoute(
              path: ':folderId',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['folderId']!);
                return FolderDetailScreen(folder: FolderModel(
                  id: id,
                  name: 'Folder',
                  colorName: 'Violet',
                  iconName: 'PhFolder',
                  isAiGenerated: true,
                  createdAt: DateTime.now(),
                  sortOrder: 0,
                ));
              },
            ),
          ],
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/document/:docId',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['docId']!);
        return DocumentDetailScreen(docId: id);
      },
    ),
  ],
);
