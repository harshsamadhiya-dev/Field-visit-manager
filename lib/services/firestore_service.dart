import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/visit.dart';
import '../models/enums.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _visits =
      FirebaseFirestore.instance.collection('visits');

  Stream<List<Visit>> watchAllVisits() {
    return _visits
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Visit.fromMap(d.id, d.data())).toList());
  }

  /// Live stream of visits assigned to a given engineer, newest first.
  Stream<List<Visit>> watchVisitsForEngineer(String engineerId) {
    return _visits
        .where('engineerId', isEqualTo: engineerId)
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Visit.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Visit>> watchActiveVisits(String engineerId) {
    return watchVisitsForEngineer(engineerId).map(
      (visits) => visits.where((v) => v.status != VisitStatus.completed).toList(),
    );
  }

  Stream<List<Visit>> watchCompletedVisits(String engineerId) {
    return watchVisitsForEngineer(engineerId).map(
      (visits) =>
          visits.where((v) => v.status == VisitStatus.completed).toList(),
    );
  }

  Future<Visit> createVisit({
    required String stationName,
    required String stationCode,
    required DeviceType deviceType,
    required String deviceId,
    required String engineerId,
    required String engineerName,
    required VisitType visitType,
    required DateTime scheduledDate,
  }) async {
    final id = const Uuid().v4();
    final visit = Visit(
      id: id,
      stationName: stationName,
      stationCode: stationCode,
      deviceType: deviceType,
      deviceId: deviceId,
      engineerId: engineerId,
      engineerName: engineerName,
      visitType: visitType,
      scheduledDate: scheduledDate,
    );
    await _visits.doc(id).set(visit.toMap());
    return visit;
  }

  Future<void> updateVisit(Visit visit) {
    return _visits.doc(visit.id).update(visit.toMap());
  }

  Future<void> startVisit(Visit visit) {
    visit.status = VisitStatus.inProgress;
    visit.startedAt = DateTime.now();
    return updateVisit(visit);
  }

  Future<void> completeVisit(Visit visit) {
    visit.status = VisitStatus.completed;
    visit.completedAt = DateTime.now();
    return updateVisit(visit);
  }

  Future<void> deleteVisit(String visitId) {
    return _visits.doc(visitId).delete();
  }
}
