import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/login_vendor_params.dart';
import '../../domain/usecases/login_vendor_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

/// BLoC managing state transitions and handling submission events for vendor login.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginVendorUseCase loginVendorUseCase;

  LoginBloc({
    required this.loginVendorUseCase,
  }) : super(const LoginInitial()) {
    on<LoginVendorSubmitted>(_onLoginVendorSubmitted);
  }

  Future<void> _onLoginVendorSubmitted(
    LoginVendorSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final params = LoginVendorParams(
      email: event.email,
      password: event.password,
    );

    final result = await loginVendorUseCase(params);

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(const LoginSuccess()),
    );
  }
}
