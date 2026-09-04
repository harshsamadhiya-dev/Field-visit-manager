import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

 Future<AppUser?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final managerDoc = await _db.collection('Managers').doc(uid).get();
    if (managerDoc.exists) {
      return AppUser.fromMap(uid, managerDoc.data()!);
    }

    final doc = await _db.collection('engineers').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(uid, doc.data()!);
    }
    // Fallback: create a minimal profile if one wasn't seeded.
    final fallback = AppUser(
      uid: uid,
      name: credential.user!.email?.split('@').first ?? 'Engineer',
      email: credential.user!.email ?? email,
      employeeId: 'N/A',
    );
    await _db.collection('engineers').doc(uid).set(fallback.toMap());
    return fallback;
  }

  Future<bool> isManager(String uid) async {
    final doc = await _db.collection('Managers').doc(uid).get();
    return doc.exists;
  }

  Future<AppUser> registerEngineer({
    required String name,
    required String email,
    required String password,
    required String employeeId,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = AppUser(
      uid: credential.user!.uid,
      name: name,
      email: email,
      employeeId: employeeId,
    );
    await _db.collection('engineers').doc(user.uid).set(user.toMap());
    return user;
  }

  Future<void> signOut() => _auth.signOut();
}
