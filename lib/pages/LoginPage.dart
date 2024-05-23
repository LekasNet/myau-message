import 'package:flutter/material.dart';
import 'package:myau_message/commons/theme.dart';
import 'package:myau_message/pages/MainPage.dart';

import '../domains/requests/loginRequest.dart';
import '../domains/requests/registrationRequest.dart';
import '../templates/loginBackgroundAnimation.dart';

void fadeTransition(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 300), // Продолжительность анимации
  ));
}


class LoginPage extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Positioned.fill(child: RiveAnimationWidget()),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Телефон',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.theme.secondaryHeaderColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Пароль',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.theme.secondaryHeaderColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkThemeColors.background03,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    onPressed: () async {
                      await login(_phoneController.text, _passwordController.text);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => MainPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Text('Вход', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      fadeTransition(context, RegistrationPage());
                    },
                    child: Text('Регистрация', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ]
      ),
    );
  }
}

class RegistrationPage extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Positioned.fill(child: RiveAnimationWidget()),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Телефон',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.theme.secondaryHeaderColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Логин',
                      prefixText: '@',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.theme.secondaryHeaderColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Пароль',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.theme.secondaryHeaderColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    onPressed: () {
                      register(_phoneController.text, _usernameController.text, _passwordController.text);
                      fadeTransition(context, LoginPage());
                    },
                    child: Text('Регистрация'),
                  ),
                  TextButton(
                    onPressed: () {
                      fadeTransition(context, LoginPage());
                    },
                    child: Text('У меня есть аккаунт', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ]
      ),
    );
  }
}


