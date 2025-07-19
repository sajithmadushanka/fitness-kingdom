import 'dart:math';

import 'package:fitness_kingdom/data/weight_entry_manager.dart';
import 'package:fitness_kingdom/models/weight_mode.dart';
import 'package:fitness_kingdom/shared/snak_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _weightController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final WeightEntryManager _weightEntryManager = WeightEntryManager();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  int? _editingIndex; // Track which entry is being edited

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Check if there's already an entry for today
  bool _hasEntryForToday(List<WeightEntry> entries) {
    final today = DateTime.now();
    return entries.any((entry) => 
        entry.date.year == today.year &&
        entry.date.month == today.month &&
        entry.date.day == today.day);
  }

  // Get today's entry if it exists
  WeightEntry? _getTodaysEntry(List<WeightEntry> entries) {
    final today = DateTime.now();
    try {
      return entries.firstWhere((entry) => 
          entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day);
    } catch (e) {
      return null;
    }
  }

  // Get today's entry index
  int? _getTodaysEntryIndex(List<WeightEntry> entries) {
    final today = DateTime.now();
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].date.year == today.year &&
          entries[i].date.month == today.month &&
          entries[i].date.day == today.day) {
        return i;
      }
    }
    return null;
  }

  Future<void> _addOrUpdateWeightEntry(List<WeightEntry> entries) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    final String weightText = _weightController.text.trim();
    final double weight = double.parse(weightText);
    
    // Simulate a brief loading for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    if (_editingIndex != null) {
      // Update existing entry
      final updatedEntry = WeightEntry(
        date: entries[_editingIndex!].date, // Keep original date
        weight: weight,
      );
      _weightEntryManager.updateEntry(_editingIndex!, updatedEntry);
      showSnackBar('Weight updated successfully!', isSuccess: true, context);
      _editingIndex = null;
    } else {
      // Check if entry for today exists
      final todaysIndex = _getTodaysEntryIndex(entries);
      if (todaysIndex != null) {
        // Update today's entry
        final updatedEntry = WeightEntry(
          date: entries[todaysIndex].date,
          weight: weight,
        );
        _weightEntryManager.updateEntry(todaysIndex, updatedEntry);
        showSnackBar('Today\'s weight updated!', isSuccess: true,context);
      } else {
        // Add new entry for today
        final newEntry = WeightEntry(date: DateTime.now(), weight: weight);
        _weightEntryManager.addEntry(newEntry);
        showSnackBar('Weight saved successfully!', isSuccess: true, context);
      }
    }
    
    _weightController.clear();
    setState(() => _isLoading = false);

    // Scroll to the end of the list after adding a new entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _editEntry(int index, WeightEntry entry) {
    setState(() {
      _editingIndex = index;
      _weightController.text = entry.weight.toString();
    });
    
    // Scroll to top to show the form
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
      _weightController.clear();
    });
  }

  void _deleteEntry(int index) {
    HapticFeedback.mediumImpact();
    _weightEntryManager.deleteEntry(index);
    showSnackBar('Entry deleted', isSuccess: true, context);
    
    // If we were editing this entry, cancel the edit
    if (_editingIndex == index) {
      _cancelEdit();
    } else if (_editingIndex != null && _editingIndex! > index) {
      // Adjust editing index if needed
      _editingIndex = _editingIndex! - 1;
    }
  }

  

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your weight';
    }
    
    final double? weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Please enter a valid number';
    }
    
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    
    if (weight > 1000) {
      return 'Please enter a realistic weight';
    }
    
    return null;
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerLowest,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Weight Tracker',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ValueListenableBuilder<List<WeightEntry>>(
        valueListenable: _weightEntryManager.weightEntriesNotifier,
        builder: (context, entries, child) {
          // Calculate statistics
          final hasData = entries.isNotEmpty;
          final currentWeight = hasData ? entries.last.weight : 0.0;
          final weightChange = hasData && entries.length > 1
              ? entries.last.weight - entries.first.weight
              : 0.0;
          final averageWeight = hasData
              ? entries.map((e) => e.weight).reduce((a, b) => a + b) / entries.length
              : 0.0;

          // Check for today's entry
          final todaysEntry = _getTodaysEntry(entries);
          final hasEntryToday = todaysEntry != null;

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Statistics Cards
                  if (hasData) ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = isTablet 
                            ? (constraints.maxWidth - 32) / 3 
                            : constraints.maxWidth;
                        
                        if (isTablet) {
                          return Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Current Weight',
                                  value: '${currentWeight.toStringAsFixed(1)} kg',
                                  icon: Icons.scale,
                                  color: theme.colorScheme.primary,
                                  subtitle: 'Latest entry',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Total Change',
                                  value: '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                                  icon: weightChange >= 0 ? Icons.trending_up : Icons.trending_down,
                                  color: weightChange >= 0 ? Colors.green : Colors.red,
                                  subtitle: 'Since first entry',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Average',
                                  value: '${averageWeight.toStringAsFixed(1)} kg',
                                  icon: Icons.analytics,
                                  color: theme.colorScheme.tertiary,
                                  subtitle: '${entries.length} entries',
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildStatCard(
                                title: 'Current Weight',
                                value: '${currentWeight.toStringAsFixed(1)} kg',
                                icon: Icons.scale,
                                color: theme.colorScheme.primary,
                                subtitle: 'Latest entry',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Change',
                                      value: '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                                      icon: weightChange >= 0 ? Icons.trending_up : Icons.trending_down,
                                      color: weightChange >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Average',
                                      value: '${averageWeight.toStringAsFixed(1)} kg',
                                      icon: Icons.analytics,
                                      color: theme.colorScheme.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                  ],

                  // Today's Entry Status (if exists)
                  if (hasEntryToday && _editingIndex == null)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: theme.colorScheme.primaryContainer,
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Today\'s Weight Recorded',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    '${todaysEntry.weight.toStringAsFixed(1)} kg at ${DateFormat('HH:mm').format(todaysEntry.date)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _editEntry(_getTodaysEntryIndex(entries)!, todaysEntry),
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              label: Text(
                                'Edit',
                                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (hasEntryToday && _editingIndex == null)
                    SizedBox(height: isTablet ? 24 : 16),

                  // Weight Input Form (only show if no entry today or editing)
                  if (!hasEntryToday || _editingIndex != null)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: theme.colorScheme.surfaceContainerLowest,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _editingIndex != null 
                                ? theme.colorScheme.primary.withOpacity(0.5)
                                : theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        padding: EdgeInsets.all(isTablet ? 28.0 : 20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _editingIndex != null ? Icons.edit : Icons.add_circle_outline,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _editingIndex != null 
                                          ? 'Edit Weight Entry'
                                          : hasEntryToday 
                                              ? 'Update Today\'s Weight'
                                              : 'Add Today\'s Weight',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (_editingIndex != null)
                                    TextButton(
                                      onPressed: _cancelEdit,
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: theme.colorScheme.error),
                                      ),
                                    ),
                                ],
                              ),
                              if (_editingIndex != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Editing entry from ${DateFormat('MMM dd, yyyy').format(entries[_editingIndex!].date)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: _validateWeight,
                                style: theme.textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  hintText: 'Enter your current weight',
                                  prefixIcon: Icon(
                                    Icons.fitness_center,
                                    color: theme.colorScheme.primary,
                                  ),
                                  suffixText: 'kg',
                                  suffixStyle: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _isLoading ? null : () => _addOrUpdateWeightEntry(entries),
                                  icon: _isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        )
                                      : Icon(_editingIndex != null ? Icons.save : Icons.save),
                                  label: Text(_isLoading 
                                      ? 'Saving...' 
                                      : _editingIndex != null 
                                          ? 'Update Entry' 
                                          : hasEntryToday 
                                              ? 'Update Today\'s Weight' 
                                              : 'Save Entry'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 18 : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (!hasEntryToday || _editingIndex != null)
                    SizedBox(height: isTablet ? 32 : 24),

                  // Weight Chart
                  if (entries.isNotEmpty)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: theme.colorScheme.surfaceContainerLowest,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        padding: EdgeInsets.all(isTablet ? 28.0 : 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.show_chart,
                                    color: theme.colorScheme.secondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Progress Chart',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: isTablet ? 300 : 250,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: theme.colorScheme.outline.withOpacity(0.2),
                                      strokeWidth: 1,
                                    ),
                                    getDrawingVerticalLine: (value) => FlLine(
                                      color: theme.colorScheme.outline.withOpacity(0.2),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          final date = DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt(),
                                          );
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              DateFormat('MMM dd').format(date),
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) => Text(
                                          value.toInt().toString(),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  minX: entries.isNotEmpty
                                      ? entries.first.date.millisecondsSinceEpoch.toDouble()
                                      : 0,
                                  maxX: entries.isNotEmpty
                                      ? entries.last.date.millisecondsSinceEpoch.toDouble()
                                      : 0,
                                  minY: entries.isNotEmpty
                                      ? (entries.map((e) => e.weight).reduce(min) - 5).floorToDouble()
                                      : 0,
                                  maxY: entries.isNotEmpty
                                      ? (entries.map((e) => e.weight).reduce(max) + 5).ceilToDouble()
                                      : 100,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: entries
                                          .map((entry) => FlSpot(
                                                entry.date.millisecondsSinceEpoch.toDouble(),
                                                entry.weight,
                                              ))
                                          .toList(),
                                      isCurved: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary.withOpacity(0.8),
                                          theme.colorScheme.primary,
                                        ],
                                      ),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                              radius: 4,
                                              color: theme.colorScheme.primary,
                                              strokeWidth: 2,
                                              strokeColor: theme.colorScheme.surface,
                                            ),
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            theme.colorScheme.primary.withOpacity(0.3),
                                            theme.colorScheme.primary.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: theme.colorScheme.surfaceContainerLowest,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        padding: EdgeInsets.all(isTablet ? 40.0 : 32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No data yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first weight entry to see your progress chart',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: isTablet ? 32 : 24),

                  // Recent Entries List
                  if (entries.isNotEmpty)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: theme.colorScheme.surfaceContainerLowest,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        padding: EdgeInsets.all(isTablet ? 28.0 : 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.history,
                                    color: theme.colorScheme.tertiary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Recent Entries',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${entries.length} total',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: entries.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: theme.colorScheme.outline.withOpacity(0.2),
                              ),
                              itemBuilder: (context, index) {
                                final entry = entries[entries.length - 1 - index]; // Reverse order
                                final isRecent = index < 3;
                                
                                return Dismissible(
                                  key: Key(entry.date.toIso8601String()),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) {
                                    HapticFeedback.mediumImpact();
                                    _weightEntryManager.deleteEntry(entries.length - 1 - index);
                                    showSnackBar('Entry deleted', isSuccess: true, context);
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: theme.colorScheme.onError,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 16 : 12,
                                      horizontal: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isRecent
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.outline.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('MMM dd, yyyy').format(entry.date),
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('HH:mm').format(entry.date),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${entry.weight.toStringAsFixed(1)} kg',
                                            style: theme.textTheme.labelMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  SizedBox(height: isTablet ? 32 : 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}