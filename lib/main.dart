import 'package:flutter/material.dart';
import 'package:myau_message/pages/LoginPage.dart';
import 'package:myau_message/pages/MainPage.dart';
import 'package:myau_message/templates/openingAnimation.dart';

import 'commons/theme.dart';
import 'domains/handlers/tokenStorage.dart';
import 'domains/requests/conversationRequest.dart';
import 'domains/requests/refreshAuth.dart';

void main() {
  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Meow message',
//       debugShowCheckedModeBanner: false,
//       themeMode: AppTheme.themeMode,
//       theme: AppTheme.theme,
//       darkTheme: AppTheme.darkTheme,
//       home: SplashScreen(),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _isLoggedIn = false;
  bool _showSplash = true;
  final TokenManager _tokenManager = TokenManager();

  void _removeSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    if (_isLoggedIn) _tokenManager.startRefreshTokenCycle();
  }

  @override
  void dispose() {
    _tokenManager.stopRefreshTokenCycle();  // Очистить ресурсы при уничтожении виджета
    super.dispose();
  }

  void _checkLoginStatus() async {
    TokenStorage storage = TokenStorage();
    var tokens = await storage.getToken();
    if (tokens['accessToken']!.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
        _initialized = true;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meow message',
      debugShowCheckedModeBanner: false,
      themeMode: AppTheme.themeMode,
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      home: Stack(
        children: [
          _isLoggedIn ? MainPage() : LoginPage(),
          if (_showSplash)
            SplashScreen(onFinish: _removeSplash),
        ],
      ),
      // _isLoggedIn ? MainPage() : LoginPage(),

    );
  }
}
