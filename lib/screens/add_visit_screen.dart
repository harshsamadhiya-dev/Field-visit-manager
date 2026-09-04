import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../services/app_state.dart';
import '../services/firestore_service.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stationNameCtrl = TextEditingController();
  final _stationCodeCtrl = TextEditingController();
  final _deviceIdCtrl = TextEditingController();
  final _firestoreService = FirestoreService();

  DeviceType _deviceType = DeviceType.uts;
  VisitType _visitType = VisitType.inspection;
  DateTime _scheduledDate = DateTime.now();
  bool _saving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final appState = context.read<AppState>();
      final user = appState.currentUser!;
      await _firestoreService.createVisit(
        stationName: _stationNameCtrl.text.trim(),
        stationCode: _stationCodeCtrl.text.trim().toUpperCase(),
        deviceType: _deviceType,
        deviceId: _deviceIdCtrl.text.trim(),
        engineerId: user.uid,
        engineerName: user.name,
        visitType: _visitType,
        scheduledDate: _scheduledDate,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Station Visit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _stationNameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Station Name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stationCodeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Station Code (e.g. NDLS)',
                    border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DeviceType>(
                initialValue: _deviceType,
                decoration: const InputDecoration(
                    labelText: 'Device Type', border: OutlineInputBorder()),
                items: DeviceType.values
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                    .toList(),
                onChanged: (v) => setState(() => _deviceType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deviceIdCtrl,
                decoration: const InputDecoration(
                    labelText: 'Device ID (e.g. UTS-04)',
                    border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VisitType>(
                initialValue: _visitType,
                decoration: const InputDecoration(
                    labelText: 'Visit Purpose', border: OutlineInputBorder()),
                items: VisitType.values
                    .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
                    .toList(),
                onChanged: (v) => setState(() => _visitType = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Scheduled Date'),
                subtitle: Text(
                    '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Schedule Visit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
