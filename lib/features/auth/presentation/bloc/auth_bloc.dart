import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_assignment/features/auth/domain/entities/user.dart';

import '../../domain/repositories/auth_repository.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    // Ensure splash screen is visible for a minimum duration
    await Future.delayed(const Duration(seconds: 2));
    
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const AuthError(message: 'Invalid credentials'));
        emit(Unauthenticated()); // Go back to unauthenticated after error
      }
    } catch (e) {
      emit(AuthError(message: 'Invalid credentials'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(Unauthenticated());
  }
}
