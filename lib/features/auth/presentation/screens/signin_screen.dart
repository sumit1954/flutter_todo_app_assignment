import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/context_extension.dart';
import '../../../../core/constants/app_strings.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          setState(() {
            _errorMessage = state.message;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.p24),
                child: _buildLoginForm(
                  context: context,
                  maxWidth: AppDimensions.webMaxWidth,
                  isLoading: state is AuthLoginLoading,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm({
    required BuildContext context,
    required double maxWidth,
    required bool isLoading,
  }) {
    final colors = context.colors;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.all(AppDimensions.p40),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r24),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: AppDimensions.p20,
            offset: const Offset(0, AppDimensions.p10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.appName,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textMain,
              ),
            ),
            const SizedBox(height: AppDimensions.p12),
            Text(
              AppStrings.welcomeBackAuth,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.p40),
            TextFormField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: AppStrings.emailLabel,
                hintText: AppStrings.emailHint,
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? AppStrings.emailError
                  : null,
            ),
            const SizedBox(height: AppDimensions.p20),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                labelText: AppStrings.passwordLabel,
                hintText: AppStrings.passwordHint,
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? AppStrings.passwordError
                  : null,
            ),
            const SizedBox(height: AppDimensions.p32),
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.surface,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.p16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      height: AppDimensions.p20,
                      width: AppDimensions.p20,
                      child: CircularProgressIndicator(
                        strokeWidth: AppDimensions.p2,
                        color: colors.surface,
                      ),
                    )
                  : Text(
                      AppStrings.signInButton,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppDimensions.p12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
