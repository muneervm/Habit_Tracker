import 'dart:async'; // Add this import
import 'package:flutter/material.dart';
import 'package:todo_list_app/widgets/sizeconfig.dart';
import 'package:todo_list_app/screens/welcome_page.dart'; // Import welcome page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.repeat(reverse: true);

    _timer = Timer(const Duration(seconds: 3), () {
      _navigateToWelcomePage();
    });
  }

  void _navigateToWelcomePage() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => Welcomepage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: SizedBox(
                width: SizeConfig.blockHeight * 20,
                height: SizeConfig.blockHeight * 20,
                child: Image.asset(
                  'assets/splashimage/todologo.png',
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
