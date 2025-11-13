import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/quiz_provider.dart';
import 'utils/app_logger.dart';
import 'services/api_service.dart';
// import file halaman 
import 'pages/splashscreen.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.init();
  await ApiService.init(); // load persisted API config early
  // Initialize AuthProvider and load saved token before launching app
  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEA App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // default mengikuti setting device
      home: SplashScreen(),
      debugShowCheckedModeBanner: false, // biar banner debug hilang
    );
  }
}
