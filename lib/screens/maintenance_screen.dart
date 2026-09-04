import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../services/firestore_service.dart';
import '../widgets/section_card.dart';

class MaintenanceScreen extends StatefulWidget {
  final Visit visit;
  const MaintenanceScreen({super.key, required this.visit});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _firestoreService = FirestoreService();
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await _firestoreService.updateVisit(widget.visit);
    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop(widget.visit);
  }

  @override
  Widget build(BuildContext context) {
    final checkedCount = widget.visit.checklist.where((c) => c.isChecked).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Preventive Maintenance - ${widget.visit.deviceId}'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: LinearProgressIndicator(
              value: checkedCount / widget.visit.checklist.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text('$checkedCount of ${widget.visit.checklist.length} tasks completed'),
          ),
          SectionCard(
            title: 'Preventive Maintenance Tasks',
            icon: Icons.build_circle_outlined,
            child: Column(
              children: widget.visit.checklist.map((item) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(item.label),
                  value: item.isChecked,
                  onChanged: (v) => setState(() => item.isChecked = v ?? false),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: _saving
              ? const SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Checklist'),
        ),
      ),
    );
  }
}
