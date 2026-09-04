import 'package:flutter/material.dart';
import '../models/enums.dart';

class StatusBadge extends StatelessWidget {
  final VisitStatus status;
  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case VisitStatus.assigned:
        return Colors.orange;
      case VisitStatus.inProgress:
        return Colors.blue;
      case VisitStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
