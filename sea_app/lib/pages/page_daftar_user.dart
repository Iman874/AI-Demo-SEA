import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page_login_user.dart'; // gunakan UserType dari sini
import '../providers/auth_provider.dart';

class PageDaftarUser extends StatefulWidget {
  final UserType userType;
  const PageDaftarUser({super.key, required this.userType});

  @override
  State<PageDaftarUser> createState() => _PageDaftarUserState();
}

class _PageDaftarUserState extends State<PageDaftarUser> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  late String _role;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _role = widget.userType == UserType.student ? 'student' : 'teacher';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
  // Use the official UNP logo for all login/register screens
  String logoAsset = 'assets/logo_unp.png';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(logoAsset, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 32),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: "Name",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          hintText: "Email",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButton<String>(
                        value: _role,
                        items: const [
                          DropdownMenuItem(value: 'student', child: Text('Student')),
                          DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _role = v ?? _role;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          _morphPageRoute(LoginUserPage(userType: widget.userType))
                        );
                      },
                      child: const Text(
                        "Log in here",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DB7B7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      onPressed: auth.loading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              final scaffold = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              final name = _nameCtrl.text.trim();
                              final email = _emailCtrl.text.trim();
                              final password = _passCtrl.text.trim();
                              if (name.isEmpty || email.isEmpty || password.isEmpty) {
                                if (!mounted) return;
                                scaffold.showSnackBar(const SnackBar(content: Text('Please complete all fields')));
                                return;
                              }
                              final ok = await auth.register(
                                name: name,
                                email: email,
                                password: password,
                                role: _role,
                              );
                              if (!mounted) return;
                              if (ok) {
                                if (!mounted) return;
                                scaffold.showSnackBar(const SnackBar(content: Text('Register successful')));
                                navigator.pushReplacement(_morphPageRoute(LoginUserPage(userType: widget.userType)));
                              } else {
                                if (!mounted) return;
                                scaffold.showSnackBar(const SnackBar(content: Text('Register failed')));
                                // Kirim Log Error ke CMD (debug only)
                                // ignore: avoid_print
                                debugPrint(ok.toString());
                              }
                            },
                      child: auth.loading ? const CircularProgressIndicator(color: Colors.white) : const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Animasi morph-style untuk transisi halaman
PageRouteBuilder _morphPageRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
