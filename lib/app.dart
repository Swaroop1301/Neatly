import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'router.dart';

class NeatlyApp extends ConsumerWidget {
  const NeatlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current theme mode and color from settings
    final themeMode = ref.watch(settingsProvider).themeMode;
    // You can also watch accent color here and pass it to ThemeData if you create an AppTheme dynamic builder

    return MaterialApp.router(
      title: 'Neatly',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
