import 'package:flutter/material.dart';
import 'package:ai_pt/src/workout_overview/workout_overview.dart';
import 'package:ai_pt/src/settings/settings_view.dart';
import 'package:ai_pt/src/storage_manager/training_logs_storage_manager.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// Dashboard with selectable time spans and multiple charts using Syncfusion Flutter Charts.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static const routeName = '/';

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final List<int> _timeSpans = [7, 30, 90, 180, 365];
  int _selectedDays = 90;
  late Future<List<Map<String, dynamic>>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    _logsFuture = TrainingLogsStorageManager().fetchItems(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.restorablePushNamed(
              context,
              SettingsView.routeName,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }

          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return const Center(
              child: Text('No workouts logged in this period.'),
            );
          }

          // Aggregate data
          final Map<DateTime, int> counts = {};
          final Map<DateTime, double> volume = {};
          final Map<DateTime, double> rpeSum = {};
          final Map<DateTime, int> rpeCount = {};

          for (var log in logs) {
            final date = DateTime.parse(log['date'] as String);
            final day = DateTime(date.year, date.month, date.day);
            counts[day] = (counts[day] ?? 0) + 1;
            final sets = double.tryParse(log['sets']) ?? 0;
            final amount = double.tryParse(log['amount']) ?? 0;
            volume[day] = (volume[day] ?? 0) + (sets * amount);
            final rpe = double.tryParse(log['rpe']) ?? 0;
            rpeSum[day] = (rpeSum[day] ?? 0) + rpe;
            rpeCount[day] = (rpeCount[day] ?? 0) + 1;
          }

          final sortedDates = counts.keys.toList()..sort();
          final countData = sortedDates.map((d) => ChartSampleData(d, counts[d]!.toDouble())).toList();
          final volumeData = sortedDates.map((d) => ChartSampleData(d, volume[d]!)).toList();
          final rpeData = sortedDates.map((d) => ChartSampleData(d, rpeSum[d]! / rpeCount[d]!)).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Time span selector with dynamic label
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Show last $_selectedDays days'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _selectedDays,
                      items: _timeSpans
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text('$d days'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedDays = val;
                            _loadLogs();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      const ChartSectionTitle('Workouts per Day'),
                      SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.Md(),
                          ),
                          series: <ChartSeries>[
                            LineSeries<ChartSampleData, DateTime>(
                              dataSource: countData,
                              xValueMapper: (d, _) => d.x,
                              yValueMapper: (d, _) => d.y,
                              markerSettings: const MarkerSettings(isVisible: true),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ChartSectionTitle('Volume (Sets × Amount)'),
                      SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.Md(),
                          ),
                          series: <ChartSeries>[
                            LineSeries<ChartSampleData, DateTime>(
                              dataSource: volumeData,
                              xValueMapper: (d, _) => d.x,
                              yValueMapper: (d, _) => d.y,
                              markerSettings: const MarkerSettings(isVisible: true),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ChartSectionTitle('Average RPE per Day'),
                      SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.Md(),
                          ),
                          series: <ChartSeries>[
                            LineSeries<ChartSampleData, DateTime>(
                              dataSource: rpeData,
                              xValueMapper: (d, _) => d.x,
                              yValueMapper: (d, _) => d.y,
                              markerSettings: const MarkerSettings(isVisible: true),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Detailed list
                      ...logs.map((logEntry) {
                        final exercise = logEntry['exercise'] as String;
                        final dateStr = logEntry['date'] as String;
                        final dateTime = DateTime.parse(dateStr);
                        final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                        final sets = logEntry['sets'] as String;
                        final amount = logEntry['amount'] as String;
                        final unit = logEntry['unit'] as String;
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
                          title: Text(exercise),
                          subtitle: Text('$formattedDate . $sets sets x $amount $unit'),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        child: FloatingActionButton(
          onPressed: () => Navigator.restorablePushNamed(
            context,
            WorkoutOverview.routeName,
          ),
          tooltip: 'Start Workout',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const FittedBox(child: Text('Start Workout')),
        ),
      ),
    );
  }
}

/// Simple model for chart data points.
class ChartSampleData {
  final DateTime x;
  final double y;
  ChartSampleData(this.x, this.y);
}

/// Section title widget for charts.
class ChartSectionTitle extends StatelessWidget {
  final String text;
  const ChartSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
}
