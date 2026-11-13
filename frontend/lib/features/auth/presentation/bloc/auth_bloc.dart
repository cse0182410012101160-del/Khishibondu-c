import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStartedEvent extends AuthEvent {}

class RequestOtpEvent extends AuthEvent {
  final String phone;
  const RequestOtpEvent(this.phone);
  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  const VerifyOtpEvent(this.phone, this.otp);
  @override
  List<Object?> get props => [phone, otp];
}

class RegisterUserEvent extends AuthEvent {
  final Map<String, dynamic> data;
  const RegisterUserEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class DemoLoginEvent extends AuthEvent {
  final String role;
  const DemoLoginEvent(this.role);
  @override
  List<Object?> get props => [role];
}

class FetchDemoAccountsEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String phone;
  final String mockOtp;
  const OtpSentState(this.phone, this.mockOtp);
  @override
  List<Object?> get props => [phone, mockOtp];
}

class NewUserNeedsRegistrationState extends AuthState {
  final String phone;
  const NewUserNeedsRegistrationState(this.phone);
  @override
  List<Object?> get props => [phone];
}

class AuthenticatedState extends AuthState {
  final UserEntity user;
  const AuthenticatedState(this.user);
  @override
  List<Object?> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class DemoAccountsLoadedState extends AuthState {
  final List<Map<String, dynamic>> accounts;
  const DemoAccountsLoadedState(this.accounts);
  @override
  List<Object?> get props => [accounts];
}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AppStartedEvent>(_onAppStarted);
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterUserEvent>(_onRegisterUser);
    on<DemoLoginEvent>(_onDemoLogin);
    on<FetchDemoAccountsEvent>(_onFetchDemoAccounts);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onAppStarted(AppStartedEvent event, Emitter<AuthState> emit) async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthenticatedState(user));
    } else {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onRequestOtp(RequestOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await _authRepository.requestOtp(event.phone);
      emit(OtpSentState(res['phone'] ?? event.phone, res['mockOtp'] ?? '123456'));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await _authRepository.verifyOtp(event.phone, event.otp);
      if (res['isNewUser'] == true) {
        emit(NewUserNeedsRegistrationState(event.phone));
      } else if (res['user'] != null) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthenticatedState(user));
        } else {
          emit(UnauthenticatedState());
        }
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onRegisterUser(RegisterUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(event.data);
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onDemoLogin(DemoLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.demoLogin(event.role);
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onFetchDemoAccounts(FetchDemoAccountsEvent event, Emitter<AuthState> emit) async {
    try {
      final accounts = await _authRepository.getDemoAccounts();
      emit(DemoAccountsLoadedState(accounts));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(UnauthenticatedState());
  }
}

