import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/enums.dart';
import '../models/visit.dart';
import '../services/firestore_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/section_card.dart';
import 'inspection_screen.dart';
import 'repair_screen.dart';
import 'install_screen.dart';
import 'maintenance_screen.dart';
import 'report_summary_screen.dart';

class VisitDetailScreen extends StatefulWidget {
  final Visit visit;
  const VisitDetailScreen({super.key, required this.visit});

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  final _firestoreService = FirestoreService();
  late Visit _visit;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _visit = widget.visit;
  }

  Future<void> _startVisit() async {
    setState(() => _busy = true);
    await _firestoreService.startVisit(_visit);
    setState(() => _busy = false);
  }

  Future<void> _goToWorkStep() async {
    Widget screen;
    switch (_visit.visitType) {
      case VisitType.inspection:
        screen = InspectionScreen(visit: _visit);
        break;
      case VisitType.repair:
        screen = RepairScreen(visit: _visit);
        break;
      case VisitType.install:
        screen = InstallScreen(visit: _visit);
        break;
      case VisitType.preventiveMaintenance:
        screen = MaintenanceScreen(visit: _visit);
        break;
    }
    final updated = await Navigator.of(context).push<Visit>(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (updated != null) setState(() => _visit = updated);
  }

  Future<void> _goToReport() async {
    final updated = await Navigator.of(context).push<Visit>(
      MaterialPageRoute(builder: (_) => ReportSummaryScreen(visit: _visit)),
    );
    if (updated != null) {
      setState(() => _visit = updated);
      if (mounted) Navigator.of(context).pop(_visit);
    }
  }

  String get _workStepLabel {
    switch (_visit.visitType) {
      case VisitType.inspection:
        return 'Fill Inspection Checklist';
      case VisitType.repair:
        return 'Log Fault & Repair';
      case VisitType.install:
        return 'Log Equipment Installation';
      case VisitType.preventiveMaintenance:
        return 'Fill Preventive Maintenance Checklist';
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _visit;
    return Scaffold(
      appBar: AppBar(title: Text('${v.stationName} Visit')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionCard(
            title: 'Visit Overview',
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Station', '${v.stationName} (${v.stationCode})'),
                _row('Device', '${v.deviceType.label} - ${v.deviceId}'),
                _row('Purpose', v.visitType.label),
                _row('Scheduled', DateFormat('dd MMM yyyy').format(v.scheduledDate)),
                if (v.startedAt != null)
                  _row('Started', DateFormat('dd MMM yyyy, hh:mm a').format(v.startedAt!)),
                if (v.completedAt != null)
                  _row('Completed', DateFormat('dd MMM yyyy, hh:mm a').format(v.completedAt!)),
                const SizedBox(height: 8),
                Row(children: [const Text('Status: '), StatusBadge(status: v.status)]),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (v.status == VisitStatus.assigned)
                  FilledButton.icon(
                    onPressed: _busy ? null : _startVisit,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Visit'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.all(14)),
                  ),
                if (v.status == VisitStatus.inProgress) ...[
                  FilledButton.icon(
                    onPressed: _goToWorkStep,
                    icon: const Icon(Icons.build_outlined),
                    label: Text(_workStepLabel),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.all(14)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _goToReport,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Complete Visit & Submit Report'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14)),
                  ),
                ],
                if (v.status == VisitStatus.completed)
                  OutlinedButton.icon(
                    onPressed: _goToReport,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('View Report'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
