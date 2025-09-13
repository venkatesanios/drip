import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CenteredLoadingIndicator extends StatelessWidget {
  final bool isVisible;
  final double? width;

  const CenteredLoadingIndicator({super.key, this.isVisible = true, this.width});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: width != null ? width! / 2 - 25 : MediaQuery.of(context).size.width / 2 - 25,
        ),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    );
  }
}