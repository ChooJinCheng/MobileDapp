import 'package:flutter/material.dart';

class WelcomeTitle extends StatefulWidget {
  const WelcomeTitle({super.key});

  @override
  State<WelcomeTitle> createState() => _WelcomeTitleState();
}

class _WelcomeTitleState extends State<WelcomeTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              const Color.fromRGBO(116, 96, 255, 1.0),
              Colors.purple.shade500,
              const Color.fromRGBO(35, 217, 157, 0.7),
            ],
            stops: [
              0.0,
              0.5 + (_animation.value - 0.5) * 0.5,
              1.0,
            ],
          ).createShader(bounds),
          child: const Text(
            'Welcome to Splidapp',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
