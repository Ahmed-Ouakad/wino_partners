import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/feature/auth/data/models/login_vendor_model.dart';
import 'package:wino_partners/feature/auth/domain/entities/auth_response.dart';
import 'package:wino_partners/feature/auth/domain/entities/login_vendor_params.dart';
import 'package:wino_partners/feature/auth/domain/entities/register_vendor_params.dart';
import 'package:wino_partners/feature/auth/domain/repositories/auth_repository.dart';
import 'package:wino_partners/feature/auth/domain/usecases/login_vendor_usecase.dart';
import 'package:wino_partners/feature/auth/presentation/bloc/login_bloc.dart';
import 'package:wino_partners/feature/auth/presentation/bloc/login_event.dart';
import 'package:wino_partners/feature/auth/presentation/bloc/login_state.dart';

class MockAuthRepository implements AuthRepository {
  Either<Failure, AuthResponse> loginResult = const Right(AuthResponse(hasService: false));

  @override
  Future<Either<Failure, AuthResponse>> loginVendor(LoginVendorParams params) async {
    return loginResult;
  }

  @override
  Future<Either<Failure, AuthResponse>> registerVendor(RegisterVendorParams params) async {
    return const Right(AuthResponse(hasService: false));
  }
}

void main() {
  group('LoginVendorModel', () {
    test('toJson returns correct keys matching API requirements', () {
      const model = LoginVendorModel(
        email: 'test@vendor.com',
        password: 'password123',
      );

      final json = model.toJson();

      expect(json, {
        'email': 'test@vendor.com',
        'password': 'password123',
      });
    });

    test('fromJson parses correctly', () {
      final json = {
        'email': 'test@vendor.com',
        'password': 'password123',
      };

      final model = LoginVendorModel.fromJson(json);

      expect(model.email, 'test@vendor.com');
      expect(model.password, 'password123');
    });
  });

  group('LoginVendorUseCase', () {
    test('should return Right(AuthResponse) on successful login from repository', () async {
      final mockRepo = MockAuthRepository();
      final useCase = LoginVendorUseCase(mockRepo);

      const params = LoginVendorParams(
        email: 'test@vendor.com',
        password: 'password123',
      );

      final result = await useCase(params);

      expect(result, const Right(AuthResponse(hasService: false)));
    });

    test('should return Left(Failure) when repository returns failure', () async {
      final mockRepo = MockAuthRepository();
      mockRepo.loginResult = const Left(ServerFailure('Invalid credentials'));
      final useCase = LoginVendorUseCase(mockRepo);

      const params = LoginVendorParams(
        email: 'test@vendor.com',
        password: 'wrong',
      );

      final result = await useCase(params);

      expect(result, const Left(ServerFailure('Invalid credentials')));
    });
  });

  group('LoginBloc', () {
    test('emits [LoginLoading, LoginSuccess] when login succeeds', () async {
      final mockRepo = MockAuthRepository();
      final useCase = LoginVendorUseCase(mockRepo);
      final bloc = LoginBloc(loginVendorUseCase: useCase);

      expectLater(
        bloc.stream,
        emitsInOrder([
          const LoginLoading(),
          const LoginSuccess(),
        ]),
      );

      bloc.add(const LoginVendorSubmitted(
        email: 'test@vendor.com',
        password: 'password123',
      ));
    });

    test('emits [LoginLoading, LoginFailure] when login fails', () async {
      final mockRepo = MockAuthRepository();
      mockRepo.loginResult = const Left(ServerFailure('Identifiants invalides'));
      final useCase = LoginVendorUseCase(mockRepo);
      final bloc = LoginBloc(loginVendorUseCase: useCase);

      expectLater(
        bloc.stream,
        emitsInOrder([
          const LoginLoading(),
          const LoginFailure('Identifiants invalides'),
        ]),
      );

      bloc.add(const LoginVendorSubmitted(
        email: 'test@vendor.com',
        password: 'wrongpassword',
      ));
    });
  });
}
