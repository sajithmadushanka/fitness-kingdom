import 'package:flutter/material.dart';

class SaveButton extends StatefulWidget {
  final bool isAddedExercise;

  const SaveButton({super.key, required this.isAddedExercise});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.05, 0), // Move slightly to the right
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
  }

  void _onTap() {
    if (widget.isAddedExercise) {
      Navigator.of(context).pop(); // Or your actual save logic
    } else {
      // Trigger "dance"
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isAddedExercise ? 1.0 : 0.4,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Slightly square
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _onTap,
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isAddedExercise ? Colors.white : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
