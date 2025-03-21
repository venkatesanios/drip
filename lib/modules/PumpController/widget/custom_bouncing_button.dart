import 'package:flutter/material.dart';

class BounceEffectButton extends StatefulWidget {
  final String label;
  final Color textColor;
  final void Function()? onTap;

  const BounceEffectButton({super.key,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  _BounceEffectButtonState createState() => _BounceEffectButtonState();
}

class _BounceEffectButtonState extends State<BounceEffectButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      if (widget.onTap != null) {
        widget.onTap!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _animation,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: widget.textColor,
          elevation: 10,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Icon(Icons.power_settings_new_rounded, color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
              // child: Text(
              //   widget.label,
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 18,
              //     shadows: [
              //       Shadow(
              //         offset: const Offset(2, 2),
              //         blurRadius: 6,
              //         color: Colors.black.withOpacity(0.3),
              //       ),
              //     ],
              //   ),
              // ),
            ),
          ),
        ),
      ),
    );
  }
}