// presentation/widgets/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final bool showBackground;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 200,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: showBackground
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset(
              'assets/animations/loading.json',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),

            // Optional message
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: showBackground ? Colors.white : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}