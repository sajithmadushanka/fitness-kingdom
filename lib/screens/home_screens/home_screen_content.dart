// Widget for the actual content of the Home tab
import 'package:fitness_kingdom/screens/home_screens/helper/activity.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Welcome message
          Text(
            'Welcome Back, [User Name]!', // Replace with dynamic user name
            style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready for your next workout?',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 24),

          // Quick Action Cards/Buttons
          Row(
            children: [
              Expanded(
                child: Card(
                  color: colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0, // Using elevation 0 as primaryContainer might be used for softer elements
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_run, size: 40, color: colorScheme.onPrimaryContainer),
                        const SizedBox(height: 12),
                        Text(
                          'Start Workout',
                          style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimaryContainer),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to workout start
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary, // Button uses primary color
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note, size: 40, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'View Plans',
                          style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Navigate to workout plans
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

          // Daily Activity Summary
          Text(
            'Daily Activity',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ActivityRow(
                    icon: Icons.local_fire_department,
                    label: 'Calories Burned',
                    value: '350 kcal',
                    iconColor: Colors.orange.shade700,
                    valueColor: colorScheme.primary,
                  ),
                  const Divider(height: 24),
                  ActivityRow(
                    icon: Icons.timer,
                    label: 'Workout Duration',
                    value: '45 min',
                    iconColor: Colors.blue.shade700,
                    valueColor: colorScheme.primary,
                  ),
                  const Divider(height: 24),
                  ActivityRow(
                    icon: Icons.directions_walk,
                    label: 'Steps Today',
                    value: '7,500 steps',
                    iconColor: Colors.green.shade700,
                    valueColor: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming Workouts/Recommendations
          Text(
            'Upcoming Workouts',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          // Example of an upcoming workout card
          Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leg Day - Strength & Endurance',
                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tomorrow, 7:00 AM',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.75, // Example progress
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: View workout details
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Another example card or a message if no upcoming workouts
          Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: colorScheme.secondary, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Discover new workout plans in the "Workouts" tab!',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}