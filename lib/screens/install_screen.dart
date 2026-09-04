import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../services/firestore_service.dart';
import '../widgets/section_card.dart';

class InstallScreen extends StatefulWidget {
  final Visit visit;
  const InstallScreen({super.key, required this.visit});

  @override
  State<InstallScreen> createState() => _InstallScreenState();
}

class _InstallScreenState extends State<InstallScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _serialCtrl;
  late TextEditingController _notesCtrl;
  final _firestoreService = FirestoreService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.visit.installedEquipmentName);
    _serialCtrl = TextEditingController(text: widget.visit.installedEquipmentSerial);
    _notesCtrl = TextEditingController(text: widget.visit.installNotes);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    widget.visit.installedEquipmentName = _nameCtrl.text.trim();
    widget.visit.installedEquipmentSerial = _serialCtrl.text.trim();
    widget.visit.installNotes = _notesCtrl.text.trim();
    setState(() => _saving = true);
    await _firestoreService.updateVisit(widget.visit);
    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop(widget.visit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Installation')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            SectionCard(
              title: 'Installed Equipment',
              icon: Icons.precision_manufacturing_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Equipment Name / Model',
                      hintText: 'e.g. New ATVM Kiosk Unit v2',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serialCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Serial / Asset Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Installation Notes',
                      hintText: 'Configuration steps, testing performed, issues faced',
                      border: OutlineInputBorder(),
                    ),
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
              : const Text('Save Installation Details'),
        ),
      ),
    );
  }
}
