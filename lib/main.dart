import 'package:flutter/material.dart';
import 'package:myau_message/pages/MainPage.dart';
import 'package:myau_message/templates/openingAnimation.dart';

import 'commons/theme.dart';

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
  bool _showSplash = true;

  void _removeSplash() {
    setState(() {
      _showSplash = false;
    });
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
          const MainPage(),
          if (_showSplash)
            SplashScreen(onFinish: _removeSplash),
        ],
      ),
    );
  }
}
