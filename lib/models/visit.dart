import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';
import 'checklist_item.dart';

class Visit {
  final String id;
  final String stationName;
  final String stationCode;
  final DeviceType deviceType;
  final String deviceId; // e.g. UTS-04, ATVM-12
  final String engineerId;
  final String engineerName;
  final VisitType visitType;
  VisitStatus status;

  final DateTime scheduledDate;
  DateTime? startedAt;
  DateTime? completedAt;

  // Inspection / Preventive Maintenance
  List<ChecklistItem> checklist;

  // Repair
  String faultDescription;
  FaultSeverity faultSeverity;
  String partsUsed;
  String repairNotes;
  bool faultResolved;

  // Install
  String installedEquipmentName;
  String installedEquipmentSerial;
  String installNotes;

  // Final report / sign-off
  String engineerRemarks;
  String? signOffName;

  Visit({
    required this.id,
    required this.stationName,
    required this.stationCode,
    required this.deviceType,
    required this.deviceId,
    required this.engineerId,
    required this.engineerName,
    required this.visitType,
    this.status = VisitStatus.assigned,
    required this.scheduledDate,
    this.startedAt,
    this.completedAt,
    List<ChecklistItem>? checklist,
    this.faultDescription = '',
    this.faultSeverity = FaultSeverity.low,
    this.partsUsed = '',
    this.repairNotes = '',
    this.faultResolved = false,
    this.installedEquipmentName = '',
    this.installedEquipmentSerial = '',
    this.installNotes = '',
    this.engineerRemarks = '',
    this.signOffName,
  }) : checklist = checklist ??
            (visitType == VisitType.preventiveMaintenance
                ? ChecklistItem.defaultPreventiveChecklist()
                : ChecklistItem.defaultInspectionChecklist());

  Map<String, dynamic> toMap() {
    return {
      'stationName': stationName,
      'stationCode': stationCode,
      'deviceType': deviceType.label,
      'deviceId': deviceId,
      'engineerId': engineerId,
      'engineerName': engineerName,
      'visitType': visitType.name,
      'status': status.name,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'checklist': checklist.map((c) => c.toMap()).toList(),
      'faultDescription': faultDescription,
      'faultSeverity': faultSeverity.name,
      'partsUsed': partsUsed,
      'repairNotes': repairNotes,
      'faultResolved': faultResolved,
      'installedEquipmentName': installedEquipmentName,
      'installedEquipmentSerial': installedEquipmentSerial,
      'installNotes': installNotes,
      'engineerRemarks': engineerRemarks,
      'signOffName': signOffName,
    };
  }

  factory Visit.fromMap(String id, Map<String, dynamic> map) {
    return Visit(
      id: id,
      stationName: map['stationName'] ?? '',
      stationCode: map['stationCode'] ?? '',
      deviceType: DeviceTypeX.fromString(map['deviceType'] ?? 'UTS'),
      deviceId: map['deviceId'] ?? '',
      engineerId: map['engineerId'] ?? '',
      engineerName: map['engineerName'] ?? '',
      visitType: VisitTypeX.fromString(map['visitType'] ?? 'inspection'),
      status: VisitStatusX.fromString(map['status'] ?? 'assigned'),
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      checklist: (map['checklist'] as List<dynamic>?)
              ?.map((c) => ChecklistItem.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      faultDescription: map['faultDescription'] ?? '',
      faultSeverity: FaultSeverityX.fromString(map['faultSeverity'] ?? 'low'),
      partsUsed: map['partsUsed'] ?? '',
      repairNotes: map['repairNotes'] ?? '',
      faultResolved: map['faultResolved'] ?? false,
      installedEquipmentName: map['installedEquipmentName'] ?? '',
      installedEquipmentSerial: map['installedEquipmentSerial'] ?? '',
      installNotes: map['installNotes'] ?? '',
      engineerRemarks: map['engineerRemarks'] ?? '',
      signOffName: map['signOffName'],
    );
  }
}
