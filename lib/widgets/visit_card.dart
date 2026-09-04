import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';
import 'status_badge.dart';

import '../models/enums.dart';

class VisitCard extends StatelessWidget {
  final Visit visit;
  final VoidCallback onTap;

  const VisitCard({super.key, required this.visit, required this.onTap});

  IconData get _icon {
    return visit.deviceType.shortLabel == 'UTS'
        ? Icons.confirmation_number_outlined
        : Icons.point_of_sale_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(_icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${visit.stationName} (${visit.stationCode})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${visit.visitType.label} | ${visit.deviceType.shortLabel} ${visit.deviceId}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(visit.scheduledDate),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: visit.status),
            ],
          ),
        ),
      ),
    );
  }
}
