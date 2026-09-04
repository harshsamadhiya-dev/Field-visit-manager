import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../services/app_state.dart';
import '../services/firestore_service.dart';
import '../widgets/visit_card.dart';
import 'add_visit_screen.dart';
import 'visit_detail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final engineerId = appState.currentUser?.uid ?? '';
    final engineerName = appState.currentUser?.name ?? 'Engineer';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $engineerName'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Visits'),
            Tab(text: 'History'),
          ],
        ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _VisitList(
            stream: _firestoreService.watchActiveVisits(engineerId),
            emptyText: 'No active visits.\nTap + to schedule a station visit.',
          ),
          _VisitList(
            stream: _firestoreService.watchCompletedVisits(engineerId),
            emptyText: 'No completed visits yet.',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddVisitScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Visit'),
      ),
    );
  }
}

class _VisitList extends StatelessWidget {
  final Stream<List<Visit>> stream;
  final String emptyText;

  const _VisitList({required this.stream, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Visit>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final visits = snapshot.data ?? [];
        if (visits.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: visits.length,
          itemBuilder: (context, index) {
            final visit = visits[index];
            return VisitCard(
              visit: visit,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => VisitDetailScreen(visit: visit)),
              ),
            );
          },
        );
      },
    );
  }
}
