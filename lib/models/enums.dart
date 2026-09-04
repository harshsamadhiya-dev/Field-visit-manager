/// Type of device an engineer works on.
enum DeviceType { uts, atvm }

extension DeviceTypeX on DeviceType {
  String get label =>
      this == DeviceType.uts ? 'UTS Counter Terminal' : 'ATVM Kiosk';

  /// Short form used for IDs/badges (e.g. "UTS-04").
  String get shortLabel => this == DeviceType.uts ? 'UTS' : 'ATVM';

  static DeviceType fromString(String value) {
    return value.toUpperCase().startsWith('UTS') ? DeviceType.uts : DeviceType.atvm;
  }
}

/// The purpose of a field visit.
enum VisitType { inspection, repair, install, preventiveMaintenance }

extension VisitTypeX on VisitType {
  String get label {
    switch (this) {
      case VisitType.inspection:
        return 'Inspection';
      case VisitType.repair:
        return 'Repair';
      case VisitType.install:
        return 'Install Equipment';
      case VisitType.preventiveMaintenance:
        return 'Preventive Maintenance';
    }
  }

  static VisitType fromString(String value) {
    return VisitType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VisitType.inspection,
    );
  }
}

/// Lifecycle status of a visit.
enum VisitStatus { assigned, inProgress, completed }

extension VisitStatusX on VisitStatus {
  String get label {
    switch (this) {
      case VisitStatus.assigned:
        return 'Assigned';
      case VisitStatus.inProgress:
        return 'In Progress';
      case VisitStatus.completed:
        return 'Completed';
    }
  }

  static VisitStatus fromString(String value) {
    return VisitStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VisitStatus.assigned,
    );
  }
}

/// Severity of a reported fault.
enum FaultSeverity { low, medium, high, critical }

extension FaultSeverityX on FaultSeverity {
  String get label {
    switch (this) {
      case FaultSeverity.low:
        return 'Low';
      case FaultSeverity.medium:
        return 'Medium';
      case FaultSeverity.high:
        return 'High';
      case FaultSeverity.critical:
        return 'Critical';
    }
  }

  static FaultSeverity fromString(String value) {
    return FaultSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FaultSeverity.low,
    );
  }
}
