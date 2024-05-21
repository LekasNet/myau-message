import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SpeedController extends SimpleAnimation {
  final double speedMultiplier;

  SpeedController(
      String animationName, {
        double mix = 1,
        this.speedMultiplier = 1,
      }) : super(
    animationName,
    mix: mix,
  );

  @override
  void apply(RuntimeArtboard artboard, double elapsedSeconds) {
    super.apply(artboard, elapsedSeconds * speedMultiplier);
  }
}


class RiveAnimationWidget extends StatefulWidget {
  @override
  _RiveAnimationWidgetState createState() => _RiveAnimationWidgetState();
}

class _RiveAnimationWidgetState extends State<RiveAnimationWidget> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Инициализация контроллера для замедленного воспроизведения
    _controller = SpeedController('Timeline 1', speedMultiplier: 0.33);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height - 140,),
      width: double.infinity, // Ширина контейнера по ширине родителя
      child: Transform(
        transform: Matrix4.diagonal3Values(1.0, 3.0, 1.0), // Масштабирование только по высоте
        alignment: Alignment.center,
        child: RiveAnimation.asset(
          'assets/animations/wave.riv',
          controllers: [_controller],
          fit: BoxFit.fitWidth, // Адаптация анимации к ширине
        ),
      ),
    );
  }
}
