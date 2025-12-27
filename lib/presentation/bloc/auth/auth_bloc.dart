import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../../domain/usecases/auth/get_cached_user_usecase.dart';
import '../../../domain/usecases/auth/get_profile_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/update_profile_usecase.dart';
import '../../../domain/usecases/usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.checkAuthStatusUseCase,
    required this.getCachedUserUseCase,
  }) : super(AuthState.initial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthGetProfile>(_onGetProfile);
    on<AuthUpdateProfile>(_onUpdateProfile);
    on<AuthClearError>(_onClearError);
  }

  /// Check authentication status
  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    final isLoggedIn = await checkAuthStatusUseCase();
    if (!isLoggedIn) {
      emit(state.unauthenticated());
      return;
    }

    // Get cached user first
    final cachedUser = await getCachedUserUseCase();
    if (cachedUser != null) {
      emit(state.authenticated(cachedUser));
    }

    // Then try to refresh from server
    final result = await getProfileUseCase(const NoParams());
    result.fold(
      (failure) {
        if (failure is AuthFailure) {
          emit(state.unauthenticated());
        } else if (cachedUser != null) {
          // Keep cached user if only network error
          emit(state.authenticated(cachedUser));
        } else {
          emit(state.unauthenticated());
        }
      },
      (user) => emit(state.authenticated(user)),
    );
  }

  /// Handle login
  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(state.error(
        failure.message,
        errors: failure is ValidationFailure ? failure.errors : null,
      )),
      (authResult) => emit(state.authenticated(authResult.user)),
    );
  }

  /// Handle register
  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    final result = await registerUseCase(RegisterParams(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
      branchId: event.branchId,
      phone: event.phone,
    ));

    result.fold(
      (failure) => emit(state.error(
        failure.message,
        errors: failure is ValidationFailure ? failure.errors : null,
      )),
      (user) {
        // Registration successful, but need to login
        emit(state.unauthenticated().copyWith(
          errorMessage: null,
        ));
      },
    );
  }

  /// Handle logout
  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    await logoutUseCase(const NoParams());
    emit(state.unauthenticated());
  }

  /// Handle get profile
  Future<void> _onGetProfile(
    AuthGetProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    final result = await getProfileUseCase(const NoParams());

    result.fold(
      (failure) {
        if (failure is AuthFailure) {
          emit(state.unauthenticated());
        } else {
          emit(state.error(failure.message));
        }
      },
      (user) => emit(state.authenticated(user)),
    );
  }

  /// Handle update profile
  Future<void> _onUpdateProfile(
    AuthUpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.profileUpdating());

    final result = await updateProfileUseCase(UpdateProfileParams(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
      avatarPath: event.avatarPath,
    ));

    result.fold(
      (failure) => emit(state.error(
        failure.message,
        errors: failure is ValidationFailure ? failure.errors : null,
      )),
      (user) => emit(state.authenticated(user)),
    );
  }

  /// Clear error
  void _onClearError(
    AuthClearError event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      errorMessage: null,
      validationErrors: null,
    ));
  }
}
