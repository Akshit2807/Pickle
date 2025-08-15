import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingHeart extends StatefulWidget {
  final double delay;

  FloatingHeart({required this.delay});

  @override
  _FloatingHeartState createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    final random = math.Random();
    _position = Tween<Offset>(
      begin: Offset(random.nextDouble() * 2 - 1, 1),
      end: Offset(random.nextDouble() * 2 - 1, -1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _opacity = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: Align(
            alignment: Alignment(_position.value.dx, _position.value.dy),
            child: Opacity(
              opacity: _opacity.value,
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
