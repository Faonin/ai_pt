import 'package:ai_pt/src/workout_creation/workout_creation_view.dart';
import 'package:ai_pt/src/workout_view/active_workout_view.dart';
import 'package:ai_pt/src/workout_view/active_workout_provider.dart';
import 'package:ai_pt/src/workout_view/active_workout_settings_view.dart';
import 'package:ai_pt/src/workout_overview/workout_adaptability_manager_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard/dashboard_view.dart';
import 'workout_overview/workout_overview.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActiveWorkoutProvider(),
      child: ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            restorationScopeId: 'app',
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  switch (routeSettings.name) {
                    case SettingsView.routeName:
                      return SettingsView(controller: settingsController);
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
              );
            },
          );
        },
      ),
    );
  }
}
