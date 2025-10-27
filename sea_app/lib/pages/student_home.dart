import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
        actions: [
          IconButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await auth.logout();
                if (!navigator.context.mounted) return;
                navigator.pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(child: Text('Welcome student: ${auth.user?.name ?? ''}')),
    );
  }
}
