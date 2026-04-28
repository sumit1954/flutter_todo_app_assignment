import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../injection_container.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/signin_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;

      final bool isAtRoot = state.matchedLocation == '/';
      final bool isLoggingIn = state.matchedLocation == '/signin';

      // 1. Handle Loading/Initial states (Stay on Splash)
      if (authState is AuthInitial || authState is AuthLoading) {
        return isAtRoot ? null : '/';
      }

      // 2. Handle Authenticated state
      if (authState is Authenticated) {
        // If on splash or signin, go to dashboard. Otherwise stay where we are.
        return (isAtRoot || isLoggingIn) ? '/dashboard' : null;
      }

      // 3. Handle Unauthenticated state
      if (authState is Unauthenticated || authState is AuthError) {
        // If not on signin page, force redirect to signin.
        return isLoggingIn ? null : '/signin';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}
