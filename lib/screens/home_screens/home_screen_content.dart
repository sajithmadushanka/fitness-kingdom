// Widget for the actual content of the Home tab
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/data/workout_days_manager.dart';
import 'package:fitness_kingdom/dialogs/workout_temp_dialog.dart';
import 'package:fitness_kingdom/screens/exercises_screens/exercises_screen.dart';
import 'package:fitness_kingdom/screens/home_screens/helper/activity.dart';
import 'package:fitness_kingdom/screens/workout_screens/workout_tranning_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<Set<String>> _weeklyWorkoutDays;
  @override
  void initState() {
    _weeklyWorkoutDays = _getWorkoutDaysThisWeek();
    super.initState();
  }

  Future<Set<String>> _getWorkoutDaysThisWeek() async {
    await WorkoutDaysManager().init(); // Ensure it's initialized
    final box = WorkoutDaysManager().workoutDaysBox;

    final now = DateTime.now();
    final start = now.subtract(Duration(days: 6));
    final formatter = DateFormat('yyyy-MM-dd');

    return box.keys.whereType<String>().where((key) {
      try {
        final date = DateTime.parse(key);
        return !date.isBefore(start) && !date.isAfter(now);
      } catch (_) {
        return false;
      }
    }).toSet();
  }

  List<String> get weekDates {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateFormat('yyyy-MM-dd').format(d);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Welcome message
          Text(
            'Welcome!', // Replace with dynamic user name
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready for your next workout?',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Action Cards/Buttons
          Row(
            children: [
              Expanded(
                child: Card(
                  color: colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation:
                      0, // Using elevation 0 as primaryContainer might be used for softer elements
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_run,
                          size: 40,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Start Workout',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutTrackingScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme
                                .primary, // Button uses primary color
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Go!'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 40,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'View Exercises',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => WorkoutTemplateDialog(),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Explore'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          //  Chart Section
          Text('This Week\'s Activity', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          FutureBuilder<Set<String>>(
            future: _weeklyWorkoutDays,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final workoutDays = snapshot.data!;
              final dates = weekDates;

              return SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(),
                      rightTitles: AxisTitles(),
                      topTitles: AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final dayIndex = value.toInt();
                            if (dayIndex < 0 || dayIndex > 6)
                              return const SizedBox();
                            final date = DateTime.parse(dates[dayIndex]);
                            return Text(DateFormat.E().format(date));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (index) {
                      final dateKey = dates[index];
                      final isWorkoutDay = workoutDays.contains(dateKey);
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: isWorkoutDay ? 1 : 0,
                            color: isWorkoutDay
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
