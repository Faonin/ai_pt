import 'package:flutter/material.dart';
import 'package:flutter_scrolling_fab_animated/flutter_scrolling_fab_animated.dart';
import 'package:flutter/rendering.dart';
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

Color get _chartLineColor => const Color(0xFFCE93D8);

class DashboardState extends State<Dashboard> {
  final ScrollController _scrollController = ScrollController();
  final List<int> _timeSpans = [7, 30, 90, 180, 365];
  int _selectedDays = 90;
  bool _fabExtended = true;
  late Future<List<Map<String, dynamic>>> _logsFuture;

  void _openWorkoutOverview() {
    Navigator.restorablePushNamed(
      context,
      WorkoutOverview.routeName,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLogs();

    _scrollController.addListener(() {
      // reverse  = scrolling down  → shrink
      // forward  = scrolling up    → extend
      final dir = _scrollController.position.userScrollDirection;
      if (dir == ScrollDirection.reverse && _fabExtended) {
        setState(() => _fabExtended = false);
      } else if (dir == ScrollDirection.forward && !_fabExtended) {
        setState(() => _fabExtended = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadLogs() {
    _logsFuture = TrainingLogsStorageManager().fetchItems(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
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
          final countData = sortedDates
              .map((d) => ChartSampleData(d, counts[d]!.toDouble()))
              .toList();
          final volumeData =
              sortedDates.map((d) => ChartSampleData(d, volume[d]!)).toList();
          final rpeData = sortedDates
              .map((d) => ChartSampleData(d, rpeSum[d]! / rpeCount[d]!))
              .toList();

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
                    controller: _scrollController,
                    children: [
                      const ChartSectionTitle('Workouts per Day'),
                      SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.Md(),
                          ),
                          series: <CartesianSeries<ChartSampleData, DateTime>>[
                            LineSeries<ChartSampleData, DateTime>(
                              dataSource: countData,
                              xValueMapper: (d, _) => d.x,
                              yValueMapper: (d, _) => d.y,
                              markerSettings:
                                  const MarkerSettings(isVisible: true),
                              color: const Color.fromARGB(255, 193, 11, 248),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ChartSectionTitle('Volume (Sets x Amount)'),
                      SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.Md(),
                          ),
                          series: <CartesianSeries<ChartSampleData, DateTime>>[
                            LineSeries<ChartSampleData, DateTime>(
                              dataSource: volumeData,
                              xValueMapper: (d, _) => d.x,
                              yValueMapper: (d, _) => d.y,
                              markerSettings:
                                  const MarkerSettings(isVisible: true),
                              color: const Color.fromARGB(255, 193, 11, 248),
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
                          series: <CartesianSeries<ChartSampleData, DateTime>>[
                            LineSeries<ChartSampleData, DateTime>(
                              dataSource: rpeData,
                              xValueMapper: (d, _) => d.x,
                              yValueMapper: (d, _) => d.y,
                              markerSettings:
                                  const MarkerSettings(isVisible: true),
                              color: const Color.fromARGB(255, 193, 11, 248),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Detailed list
                      const ChartSectionTitle('Workout History'),
                      ...logs.map((logEntry) {
                        final exercise = logEntry['exercise'] as String;
                        final dateStr = logEntry['date'] as String;
                        final dateTime = DateTime.parse(dateStr);
                        final formattedDate =
                            DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                        final sets = logEntry['sets'] as String;
                        final amount = logEntry['amount'] as String;
                        final unit = logEntry['unit'] as String;
                        return ListTile(
                          leading: const CircleAvatar(
                              child: Icon(Icons.fitness_center)),
                          title: Text(exercise),
                          subtitle: Text(
                              '$formattedDate . $sets sets x $amount $unit'),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ScrollingFabAnimated(
        color: Theme.of(context).colorScheme.primary,
        icon: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        text: Text(
          'Start Workout',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 16,
          ),
        ),
        onPress: _openWorkoutOverview,
        scrollController: _scrollController,
        inverted: false,
        animateIcon: false,
        width: 170.0, // expanded width
        height: 56.0, // also collapsed diameter
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        radius: 20.0,
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
