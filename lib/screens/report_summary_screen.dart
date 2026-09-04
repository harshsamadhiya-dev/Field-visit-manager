import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/enums.dart';
import '../models/visit.dart';
import '../services/firestore_service.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

class ReportSummaryScreen extends StatefulWidget {
  final Visit visit;
  const ReportSummaryScreen({super.key, required this.visit});

  @override
  State<ReportSummaryScreen> createState() => _ReportSummaryScreenState();
}

class _ReportSummaryScreenState extends State<ReportSummaryScreen> {
  final _firestoreService = FirestoreService();
  late TextEditingController _remarksCtrl;
  late TextEditingController _signOffCtrl;
  bool _saving = false;

  bool get _isCompleted => widget.visit.status == VisitStatus.completed;

  @override
  void initState() {
    super.initState();
    _remarksCtrl = TextEditingController(text: widget.visit.engineerRemarks);
    _signOffCtrl = TextEditingController(text: widget.visit.signOffName ?? '');
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    widget.visit.engineerRemarks = _remarksCtrl.text.trim();
    widget.visit.signOffName = _signOffCtrl.text.trim();
    await _firestoreService.completeVisit(widget.visit);
    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop(widget.visit);
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.visit;
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Report')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          SectionCard(
            title: 'Summary',
            icon: Icons.summarize_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Station', '${v.stationName} (${v.stationCode})'),
                _row('Device', '${v.deviceType.label} - ${v.deviceId}'),
                _row('Purpose', v.visitType.label),
                _row('Engineer', v.engineerName),
                if (v.startedAt != null)
                  _row('Started', DateFormat('dd MMM yyyy, hh:mm a').format(v.startedAt!)),
                const SizedBox(height: 8),
                Row(children: [const Text('Status: '), StatusBadge(status: v.status)]),
              ],
            ),
          ),
          if (v.visitType == VisitType.inspection ||
              v.visitType == VisitType.preventiveMaintenance)
            SectionCard(
              title: 'Checklist Results',
              icon: Icons.checklist_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: v.checklist.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          c.isChecked ? Icons.check_circle : Icons.cancel,
                          color: c.isChecked ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(c.label)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          if (v.visitType == VisitType.repair)
            SectionCard(
              title: 'Fault & Repair',
              icon: Icons.report_problem_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Fault', v.faultDescription.isEmpty ? '—' : v.faultDescription),
                  _row('Severity', v.faultSeverity.label),
                  _row('Parts Used', v.partsUsed.isEmpty ? '—' : v.partsUsed),
                  _row('Notes', v.repairNotes.isEmpty ? '—' : v.repairNotes),
                  _row('Resolved', v.faultResolved ? 'Yes' : 'No'),
                ],
              ),
            ),
          if (v.visitType == VisitType.install)
            SectionCard(
              title: 'Equipment Installed',
              icon: Icons.precision_manufacturing_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Equipment', v.installedEquipmentName.isEmpty
                      ? '—'
                      : v.installedEquipmentName),
                  _row('Serial No.', v.installedEquipmentSerial.isEmpty
                      ? '—'
                      : v.installedEquipmentSerial),
                  _row('Notes', v.installNotes.isEmpty ? '—' : v.installNotes),
                ],
              ),
            ),
          SectionCard(
            title: 'Engineer Sign-off',
            icon: Icons.edit_note_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _remarksCtrl,
                  maxLines: 3,
                  enabled: !_isCompleted,
                  decoration: const InputDecoration(
                    labelText: 'Overall Remarks',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _signOffCtrl,
                  enabled: !_isCompleted,
                  decoration: const InputDecoration(
                    labelText: 'Engineer Sign-off Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isCompleted
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: _saving
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Report & Complete Visit'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
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
