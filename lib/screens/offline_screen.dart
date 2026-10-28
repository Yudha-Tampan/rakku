import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rakku/app_chrome.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.onRetry,
  });

  final String title;
  final String message;
  final IconData icon;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppOverlayStyle,
      child: Scaffold(
        backgroundColor: kAppBackground,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kAppBackground, kAppBackgroundElevated],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 56, color: kAppAccent),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kAppTextSecondary),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kAppPurple,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: onRetry,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
