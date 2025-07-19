import 'package:fitness_kingdom/models/exercise.dart';
import 'package:fitness_kingdom/shared/snak_bar.dart';
import 'package:flutter/material.dart';

class ExerciseInfoScreen extends StatefulWidget {
  final ExerciseModel exercise;
  const ExerciseInfoScreen({super.key, required this.exercise});

  @override
  State<ExerciseInfoScreen> createState() => _ExerciseInfoScreenState();
}

class _ExerciseInfoScreenState extends State<ExerciseInfoScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Add scroll listener for app bar animation
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 100 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildHeaderSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Size screenSize,
  ) {
    final isTablet = screenSize.width > 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.primary.withOpacity(0.1), colorScheme.surface],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
        child: Column(
          children: [
            // Exercise Image
            Hero(
              tag: 'exercise_${widget.exercise.name}',
              child: Container(
                width: isTablet ? 200 : 150,
                height: isTablet ? 200 : 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.exercise.image.isNotEmpty
                      ? Image.asset(widget.exercise.image, fit: BoxFit.cover)
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary.withOpacity(0.3),
                                colorScheme.primary.withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: colorScheme.onPrimary,
                            size: isTablet ? 80 : 60,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Exercise Name
            Text(
              widget.exercise.name,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                widget.exercise.category,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isTablet,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      padding: EdgeInsets.all(isTablet ? 28.0 : 20.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.list_alt_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Instructions',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Instructions List
          if (widget.exercise.instructions.isNotEmpty)
            ...widget.exercise.instructions.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Number
                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(right: 12, top: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Instruction Text
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              instruction,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                height: 1.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
          else
            // No instructions available
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No instructions available',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Animated App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            elevation: _isScrolled ? 4 : 0,
            backgroundColor: _isScrolled
                ? colorScheme.surface.withOpacity(0.95)
                : Colors.transparent,
            foregroundColor: colorScheme.onSurface,
            title: AnimatedOpacity(
              opacity: _isScrolled ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                widget.exercise.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isScrolled
                    ? Colors.transparent
                    : colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isScrolled
                      ? Colors.transparent
                      : colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    showSnackBar(
                      "Added to favorites!",
                      context,
                      isSuccess: true,
                    );
                  },
                  icon: Icon(
                    Icons.favorite_border_rounded,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(colorScheme, theme.textTheme, screenSize),

                // Instructions Section
                _buildInstructionsSection(
                  colorScheme,
                  theme.textTheme,
                  isTablet,
                ),

                // Bottom Padding
                SizedBox(height: mediaQuery.padding.bottom + 20),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button for Quick Actions
      // floatingActionButton: FadeTransition(
      //   opacity: _fadeAnimation,
      //   child: FloatingActionButton.extended(
      //     onPressed: () {
      //       // Start workout functionality
      //       showDialog(
      //         context: context,
      //         builder: (context) => AlertDialog(
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(16),
      //           ),
      //           title: Text('Start Workout'),
      //           content: Text('Ready to start this exercise?'),
      //           actions: [
      //             TextButton(
      //               onPressed: () => Navigator.pop(context),
      //               child: Text('Cancel'),
      //             ),
      //             FilledButton(
      //               onPressed: () {
      //                 Navigator.pop(context);
      //                 ScaffoldMessenger.of(context).showSnackBar(
      //                   SnackBar(
      //                     content: Text('Workout started! 💪'),
      //                     behavior: SnackBarBehavior.floating,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                   ),
      //                 );
      //               },
      //               child: Text('Start'),
      //             ),
      //           ],
      //         ),
      //       );
      //     },
      //     backgroundColor: colorScheme.primary,
      //     foregroundColor: colorScheme.onPrimary,
      //     icon: const Icon(Icons.play_arrow_rounded),
      //     label: const Text('Start Workout'),
      //   ),
      // ),
    );
  }
}
