import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/register_vendor_params.dart';
import '../../domain/usecases/register_vendor_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

/// BLoC managing the state transitions and handling submission events for vendor registration.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterVendorUseCase registerVendorUseCase;

  RegisterBloc({
    required this.registerVendorUseCase,
  }) : super(const RegisterInitial()) {
    on<RegisterVendorSubmitted>(_onRegisterVendorSubmitted);
  }

  Future<void> _onRegisterVendorSubmitted(
    RegisterVendorSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());

    final params = RegisterVendorParams(
      email: event.email,
      password: event.password,
      fullname: event.fullname,
      phoneNumber: event.phoneNumber,
      vendorType: event.vendorType,
    );

    final result = await registerVendorUseCase(params);

    result.fold(
      (failure) => emit(RegisterFailure(failure.message)),
      (_) => emit(const RegisterSuccess()),
    );
  }
}
