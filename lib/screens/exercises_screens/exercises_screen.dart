import 'package:fitness_kingdom/screens/exercises_screens/exercise_info_screen.dart';
import 'package:fitness_kingdom/screens/home_screens/home_screen.dart';
import 'package:fitness_kingdom/shared/get_filterd_exercises.dart';
import 'package:flutter/material.dart';

import '../../data/load_exercise.dart';
import '../../models/exercise.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with TickerProviderStateMixin {
  String searchQuery = "";
  String selectedCategory = 'All Categories';
  bool isSearchFocused = false;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  late Future<Map<String, ExerciseModel>> exercisesFuture;

  // Predefined list of categories with icons
  final List<Map<String, dynamic>> categories = [
    {'name': 'All Categories', 'icon': Icons.grid_view_rounded},
    {'name': 'Chest', 'icon': Icons.fitness_center},
    {'name': 'Back', 'icon': Icons.sports_gymnastics},
    {'name': 'Shoulders', 'icon': Icons.accessible_forward},
    {'name': 'Biceps', 'icon': Icons.sports_handball},
    {'name': 'Triceps', 'icon': Icons.sports_martial_arts},
    {'name': 'Abs', 'icon': Icons.sports_kabaddi},
    {'name': 'Legs', 'icon': Icons.directions_run},
  ];

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) {
      return;
    }
    exercisesFuture = loadExercises(context);
  }

  void _toggleFilterVisibility() {
    if (_filterAnimationController.isCompleted) {
      _filterAnimationController.reverse();
    } else {
      _filterAnimationController.forward();
    }
  }

  Widget _buildCategoryChip(String categoryName, IconData icon, bool isSelected, ColorScheme colorScheme, TextTheme textTheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = categoryName;
          });
        },
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected 
              ? colorScheme.onPrimary 
              : colorScheme.onSurfaceVariant,
        ),
        label: Text(
          categoryName,
          style: textTheme.bodySmall?.copyWith(
            color: isSelected 
                ? colorScheme.onPrimary 
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        checkmarkColor: colorScheme.onPrimary,
        side: BorderSide(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.surfaceContainerHighest,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseInfoScreen(exercise: exercise),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Exercise image container
                Hero(
                  tag: 'exercise_${exercise.name}',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: exercise.image.isNotEmpty
                          ? Image.asset(
                              exercise.image,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary.withValues(alpha: 0.1),
                                    colorScheme.primary.withValues(alpha: 0.2),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.fitness_center,
                                color: colorScheme.primary,
                                size: 28,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Exercise details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          exercise.category,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return Scaffold(
      body: SizedBox(
        width: mediaQuery.size.width,
        height: mediaQuery.size.height * 0.8,
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSearchFocused 
                            ? colorScheme.primary.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSearchFocused
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: TextField(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search exercises...",
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isSearchFocused
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchQuery = "";
                                  });
                                },
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              )
                            : IconButton(
                                onPressed: _toggleFilterVisibility,
                                icon: AnimatedRotation(
                                  turns: _filterAnimation.value * 0.5,
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      onTap: () {
                        setState(() {
                          isSearchFocused = true;
                        });
                      },
                      onTapOutside: (_) {
                        setState(() {
                          isSearchFocused = false;
                        });
                      },
                    ),
                  ),

                  // Category Filter Chips
                  SizeTransition(
                    sizeFactor: _filterAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categories',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected = selectedCategory == category['name'];
                                return _buildCategoryChip(
                                  category['name'],
                                  category['icon'],
                                  isSelected,
                                  colorScheme,
                                  theme.textTheme,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Exercise List
            Expanded(
              child: FutureBuilder<Map<String, ExerciseModel>>(
                future: exercisesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: colorScheme.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading exercises...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: colorScheme.onErrorContainer,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Oops! Something went wrong',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unable to load exercises. Please try again.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done &&
                      (snapshot.hasData && snapshot.data!.isNotEmpty)) {
                    final allExercises = snapshot.data!;
                    final filteredExercises = getFilteredExercises(
                      allExercises,
                      searchQuery,
                      selectedCategory,
                    );

                    if (filteredExercises.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No exercises found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          exercisesFuture = loadExercises(context);
                        });
                      },
                      color: colorScheme.primary,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24.0 : 16.0,
                          vertical: 8.0,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exerciseEntry = filteredExercises[index];
                          final exercise = exerciseEntry.value;
                          return _buildExerciseCard(
                            exercise,
                            colorScheme,
                            theme.textTheme,
                          );
                        },
                      ),
                    );
                  }

                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises available',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}