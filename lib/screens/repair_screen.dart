import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/visit.dart';
import '../services/firestore_service.dart';
import '../widgets/section_card.dart';

class RepairScreen extends StatefulWidget {
  final Visit visit;
  const RepairScreen({super.key, required this.visit});

  @override
  State<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _faultCtrl;
  late TextEditingController _partsCtrl;
  late TextEditingController _notesCtrl;
  final _firestoreService = FirestoreService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _faultCtrl = TextEditingController(text: widget.visit.faultDescription);
    _partsCtrl = TextEditingController(text: widget.visit.partsUsed);
    _notesCtrl = TextEditingController(text: widget.visit.repairNotes);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    widget.visit.faultDescription = _faultCtrl.text.trim();
    widget.visit.partsUsed = _partsCtrl.text.trim();
    widget.visit.repairNotes = _notesCtrl.text.trim();
    setState(() => _saving = true);
    await _firestoreService.updateVisit(widget.visit);
    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop(widget.visit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fault Repair')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            SectionCard(
              title: 'Fault Details',
              icon: Icons.report_problem_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _faultCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Fault Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<FaultSeverity>(
                    initialValue: widget.visit.faultSeverity,
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      border: OutlineInputBorder(),
                    ),
                    items: FaultSeverity.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => widget.visit.faultSeverity = v ?? FaultSeverity.low),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: 'Repair Action',
              icon: Icons.handyman_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _partsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Parts / Components Replaced',
                      hintText: 'e.g. Thermal printer head, power adapter',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Repair Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fault Resolved'),
                    value: widget.visit.faultResolved,
                    onChanged: (v) => setState(() => widget.visit.faultResolved = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: _saving
              ? const SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Repair Details'),
        ),
      ),
    );
  }
}
