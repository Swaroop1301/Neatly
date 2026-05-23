import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create database if not exists
  await AppDatabase.instance.database;

  // For testing purposes, uncomment to simulate first launch
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('isFirstLaunch', true);

  runApp(
    const ProviderScope(
      child: NeatlyApp(),
    ),
  );
}
