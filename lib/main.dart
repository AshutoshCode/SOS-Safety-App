import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'config/firebase_config.dart';
import 'core/services/service_locator.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/emergency/presentation/screens/home_screen.dart';
import 'features/emergency/presentation/providers/emergency_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase configuration
  await FirebaseConfig.initialize();

  // Setup GetIt service locator
  setupServiceLocator();

  runApp(const SilentEmergencyAlertApp());
}

class SilentEmergencyAlertApp extends StatelessWidget {
  const SilentEmergencyAlertApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmergencyProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Silent Emergency Alert',
        theme: ThemeData(
          primarySwatch: Colors.red,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.red,
            accentColor: Colors.redAccent,
          ),
        ),
        routerConfig: _buildRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final authProvider = context.read<AuthProvider>();
            return authProvider.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        if (!authProvider.isAuthenticated &&
            state.matchedLocation != '/login') {
          return '/login';
        }
        return null;
      },
    );
  }
}
