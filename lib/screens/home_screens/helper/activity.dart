import 'package:flutter/material.dart';

class ActivityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color valueColor;

  const ActivityRow({super.key, 
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: valueColor),
        ),
      ],
    );
  }
}
