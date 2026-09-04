class ChecklistItem {
  final String id;
  final String label;
  bool isChecked;
  String remarks;

  ChecklistItem({
    required this.id,
    required this.label,
    this.isChecked = false,
    this.remarks = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'isChecked': isChecked,
      'remarks': remarks,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      isChecked: map['isChecked'] ?? false,
      remarks: map['remarks'] ?? '',
    );
  }

  /// Standard checklist for a UTS/ATVM device inspection.
  static List<ChecklistItem> defaultInspectionChecklist() {
    const labels = [
      'Power supply & UPS backup functioning',
      'Display screen clear and responsive',
      'Printer / thermal head working correctly',
      'Cash / coin acceptor functioning (ATVM)',
      'Smart card reader functioning (UTS)',
      'Network / connectivity module active',
      'Housing and keypad physically intact',
      'Ventilation and cooling fan working',
      'Software version up to date',
      'Error logs reviewed for recurring issues',
    ];
    return labels
        .asMap()
        .entries
        .map((e) => ChecklistItem(id: 'insp_${e.key}', label: e.value))
        .toList();
  }

  /// Standard checklist for preventive maintenance.
  static List<ChecklistItem> defaultPreventiveChecklist() {
    const labels = [
      'Clean external casing and vents',
      'Clean and lubricate printer mechanism',
      'Check and tighten cable connections',
      'Test UPS battery backup duration',
      'Update firmware/software if available',
      'Clean card reader / coin acceptor sensors',
      'Verify grounding and electrical safety',
      'Back up transaction logs',
      'Calibrate touch screen (if applicable)',
      'Replace consumables (paper roll, ribbon, etc.)',
    ];
    return labels
        .asMap()
        .entries
        .map((e) => ChecklistItem(id: 'pm_${e.key}', label: e.value))
        .toList();
  }
}
