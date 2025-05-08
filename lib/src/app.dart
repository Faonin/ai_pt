import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dashboard/dashboard_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'workout_creation/workout_creation_view.dart';
import 'workout_overview/workout_overview.dart';
import 'workout_overview/workout_adaptability_manager_view.dart';
import 'workout_view/active_workout_provider.dart';
import 'workout_view/active_workout_settings_view.dart';
import 'workout_view/active_workout_view.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) await Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light);
    final darkScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark);

    ThemeData theme(ColorScheme scheme) => ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          appBarTheme: const AppBarTheme(centerTitle: true),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            sizeConstraints: const BoxConstraints.tightFor(width: 72, height: 72),
            elevation: 6,
          ),
          cardTheme: CardTheme(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            shadowColor: Colors.black26,
          ),
        );

    return ChangeNotifierProvider(
      create: (_) => ActiveWorkoutProvider(),
      child: ListenableBuilder(
        listenable: widget.settingsController,
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          theme: theme(lightScheme),
          darkTheme: theme(darkScheme),
          themeMode: widget.settingsController.themeMode,
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) {
              switch (settings.name) {
                case SettingsView.routeName:
                  return SettingsView(controller: widget.settingsController);
                case WorkoutCreationView.routeName:
                  return const WorkoutCreationView();
                case WorkoutOverview.routeName:
                  return WorkoutOverview();
                case WorkoutAdaptabilityManager.routeName:
                  return WorkoutAdaptabilityManager();
                case ActiveWorkoutView.routeName:
                  return const ActiveWorkoutView();
                case ActiveWorkoutSettings.routeName:
                  return ActiveWorkoutSettings();
                case Dashboard.routeName:
                default:
                  return Dashboard();
              }
            },
          ),
        ),
      ),
    );
  }
}
