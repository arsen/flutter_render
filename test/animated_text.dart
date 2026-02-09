import 'package:flutter/material.dart';

class AnimatedScaledText extends StatelessWidget {
  const AnimatedScaledText({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const ValueKey('capture'),
      child: Container(
        width: 300,
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) => Transform.scale(
              scale: animation.value, // 0.0 -> 1.0
              alignment: Alignment.center,
              child: child,
            ),
            child: const Text(
              'Hello from Flutter!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontFamily: 'Roboto', // you already loaded/registered Roboto
              ),
            ),
          ),
        ),
      ),
    );
  }
}