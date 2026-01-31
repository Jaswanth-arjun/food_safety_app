import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final bool circle;
  final BoxFit fit;

  const BrandLogo({super.key, this.size = 24.0, this.circle = false, this.fit = BoxFit.contain});

  // Convenience named constructors for common sizes
  const BrandLogo.small({super.key, this.circle = false}) : size = 20.0, fit = BoxFit.contain;
  const BrandLogo.medium({super.key, this.circle = false}) : size = 36.0, fit = BoxFit.contain;
  const BrandLogo.large({super.key, this.circle = false}) : size = 64.0, fit = BoxFit.contain;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'logo.png',
      width: size,
      height: size,
      fit: fit,
    );

    if (circle) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: logo,
        ),
      );
    }

    return logo;
  }
}

class LogoSpinner extends StatefulWidget {
  final double size;
  final Duration duration;

  const LogoSpinner({super.key, this.size = 28.0, this.duration = const Duration(seconds: 1)});

  // Named constructors for convenience sizes
  const LogoSpinner.small({super.key}) : size = 20.0, duration = const Duration(seconds: 1);
  const LogoSpinner.medium({super.key}) : size = 36.0, duration = const Duration(seconds: 1);
  const LogoSpinner.large({super.key}) : size = 64.0, duration = const Duration(seconds: 1);

  @override
  State<LogoSpinner> createState() => _LogoSpinnerState();
}

class _LogoSpinnerState extends State<LogoSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: BrandLogo(size: widget.size, circle: true),
    );
  }
}
