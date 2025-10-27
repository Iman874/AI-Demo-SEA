import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Home'),
        actions: [
          IconButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await auth.logout();
                navigator.pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(child: Text('Welcome teacher: ${auth.user?.name ?? ''}')),
    );
  }
}
