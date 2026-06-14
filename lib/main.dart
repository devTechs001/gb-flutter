import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/status_provider.dart';
import 'providers/call_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/privacy_provider.dart';
import 'widgets/socket_listener.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZenoApp());
}

class ZenoApp extends StatelessWidget {
  const ZenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PrivacyProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, tp, _) => MaterialApp(
          title: 'ChatWave',
          debugShowCheckedModeBanner: false,
          theme: tp.currentTheme,
          home: SocketListener(
            child: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
