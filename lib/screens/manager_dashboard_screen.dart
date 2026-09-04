import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../services/app_state.dart';
import '../services/firestore_service.dart';
import '../widgets/visit_card.dart';
import 'visit_detail_screen.dart';
import 'login_screen.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final firestoreService = FirestoreService();
    final manager = appState.currentUser;
    final managerLabel = manager == null
        ? 'Manager'
        : manager.name.trim().isNotEmpty
            ? manager.name
            : manager.email.trim().isNotEmpty
                ? manager.email
                : manager.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $managerLabel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await appState.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Visit>>(
        stream: firestoreService.watchAllVisits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final visits = snapshot.data ?? [];
          if (visits.isEmpty) {
            return const Center(child: Text('No visits have been scheduled yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      visit.engineerName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  VisitCard(
                    visit: visit,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => VisitDetailScreen(visit: visit)),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
