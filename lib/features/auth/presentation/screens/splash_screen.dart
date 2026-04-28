import 'package:flutter/material.dart';
import '../../../../core/theme/context_extension.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.appName,
              style: context.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.p24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
