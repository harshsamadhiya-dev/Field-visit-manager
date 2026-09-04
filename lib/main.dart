import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/app_user.dart';
import 'services/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/manager_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FieldVisitManagerApp());
}

class FieldVisitManagerApp extends StatelessWidget {
  const FieldVisitManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Field Visit Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF0D47A1),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// Decides whether to show Login or Dashboard based on Firebase auth state,
/// and hydrates the AppState with the matching engineer profile.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final firebaseUser = snapshot.data;
        if (firebaseUser == null) {
          return const LoginScreen();
        }
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('Managers')
              .doc(firebaseUser.uid)
              .get(),
          builder: (context, managerSnap) {
            if (managerSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (managerSnap.hasData && managerSnap.data!.exists) {
              final user = AppUser.fromMap(firebaseUser.uid, managerSnap.data!.data()!);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AppState>().setUser(user);
                context.read<AppState>().setIsManager(true);
              });
              return const ManagerDashboardScreen();
            }
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('engineers')
                  .doc(firebaseUser.uid)
                  .get(),
              builder: (context, profileSnap) {
                if (profileSnap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (profileSnap.hasData && profileSnap.data!.exists) {
                  final user = AppUser.fromMap(firebaseUser.uid, profileSnap.data!.data()!);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<AppState>().setUser(user);
                    context.read<AppState>().setIsManager(false);
                  });
                  return const DashboardScreen();
                }
                return const LoginScreen();
              },
            );
          },
        );
      },
    );
  }
}
