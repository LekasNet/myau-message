import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:myau_message/commons/theme.dart';
import 'package:myau_message/pages/LoginPage.dart';

import '../domains/handlers/tokenStorage.dart';


class AvatarButton extends StatefulWidget {
  final VoidCallback? onTap; // Добавляем callback для обработки нажатия

  AvatarButton({this.onTap});

  @override
  _AvatarButtonState createState() => _AvatarButtonState();
}

class _AvatarButtonState extends State<AvatarButton> with SingleTickerProviderStateMixin {
  bool isInTournament = false; // Начальное состояние

  void toggleState() {
    setState(() {
    });
    _gotoDetailsPage(context);
  }

  void _gotoDetailsPage(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Фиксированные координаты центра кнопки
    final Offset buttonCenter = Offset(screenWidth - 18 - 25, MediaQuery.of(context).padding.top + 45 + 23);

    // Вычисляем максимальный радиус для полного покрытия экрана
    final double radius = math.sqrt(math.pow(screenWidth, 2) + math.pow(screenHeight, 2));

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => DetailsPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        // Анимация для покрытия экрана с помощью круга
        var circleRadius = Tween(begin: 0.0, end: radius).evaluate(curvedAnimation);
        var circleOpacity = Tween(begin: 0.0, end: 1.0).evaluate(curvedAnimation);

        return AnimatedBuilder(
          animation: curvedAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                ClipPath(
                  clipper: CircleRevealClipper(buttonCenter, circleRadius),
                  child: child,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(0, -0.6),
                    child: FadeTransition(
                      opacity: curvedAnimation,
                      child: CircleAvatar(
                        backgroundImage: const NetworkImage('https://avatars.cloudflare.steamstatic.com/b2d93ef9b6fe943afa8744a635f99285ad3c73e8_full.jpg'),
                        radius: 80 * circleOpacity, // Динамическое изменение размера в зависимости от анимации
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    ));

  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          toggleState();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(3),  // Отступ для создания кольца
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isInTournament ? Colors.blue : AppTheme.colors.background01,  // Цвет кольца
        ),
        child: CircleAvatar(
          backgroundImage: const NetworkImage('https://avatars.cloudflare.steamstatic.com/b2d93ef9b6fe943afa8744a635f99285ad3c73e8_full.jpg'),
          backgroundColor: isInTournament ? Colors.green : Colors.red,
          radius: 25,  // Размер внутреннего аватара
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(child: SafeArea(child: Stack(children: [
      Scaffold(
        appBar: AppBar(title: const Text('Настройки')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Details Screen', style: Theme.of(context).textTheme.headline4),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  TokenStorage storage = TokenStorage();
                  await storage.clearTokens();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.redAccent, // Text Color (Foreground color)
                ),
              ),
            ],
          ),
        ),
      ),
    ]
    )
    )
    );
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleRevealClipper(this.center, this.radius);

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) => radius != oldClipper.radius || center != oldClipper.center;
}

