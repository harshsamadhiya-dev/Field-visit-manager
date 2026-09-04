import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../services/firestore_service.dart';
import '../widgets/section_card.dart';

import '../models/enums.dart';

class InspectionScreen extends StatefulWidget {
  final Visit visit;
  const InspectionScreen({super.key, required this.visit});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
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
        title: Text('Inspection - ${widget.visit.deviceType.shortLabel} ${widget.visit.deviceId}'),
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
            child: Text('$checkedCount of ${widget.visit.checklist.length} items checked'),
          ),
          SectionCard(
            title: 'Device Inspection Checklist',
            icon: Icons.checklist_outlined,
            child: Column(
              children: widget.visit.checklist.map((item) {
                return Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(item.label),
                      value: item.isChecked,
                      onChanged: (v) => setState(() => item.isChecked = v ?? false),
                    ),
                    if (!item.isChecked)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 4, bottom: 8),
                        child: TextFormField(
                          initialValue: item.remarks,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Remarks (optional, e.g. reason for defect)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => item.remarks = v,
                        ),
                      ),
                    const Divider(height: 8),
                  ],
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
