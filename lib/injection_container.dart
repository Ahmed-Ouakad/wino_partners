import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'core/services/secure_caching_service.dart';
import 'feature/auth/data/datasources/auth_remote_data_source.dart';
import 'feature/auth/data/repositories/auth_repository_impl.dart';
import 'feature/auth/domain/repositories/auth_repository.dart';
import 'feature/auth/domain/usecases/login_vendor_usecase.dart';
import 'feature/auth/domain/usecases/register_vendor_usecase.dart';
import 'feature/auth/presentation/bloc/login_bloc.dart';
import 'feature/auth/presentation/bloc/register_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes and registers all application dependencies with [GetIt].
Future<void> init() async {
  //! External Dependencies
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  //! Core / Services
  sl.registerLazySingleton<SecureCachingService>(
    () => SecureCachingServiceImpl(secureStorage: sl()),
  );

  //! 1. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  //! 2. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureCachingService: sl(),
    ),
  );

  //! 3. Use Cases
  sl.registerLazySingleton<RegisterVendorUseCase>(
    () => RegisterVendorUseCase(sl()),
  );
  sl.registerLazySingleton<LoginVendorUseCase>(
    () => LoginVendorUseCase(sl()),
  );

  //! 4. BLoC (Presentation)
  sl.registerFactory<RegisterBloc>(
    () => RegisterBloc(registerVendorUseCase: sl()),
  );
  sl.registerFactory<LoginBloc>(
    () => LoginBloc(loginVendorUseCase: sl()),
  );
}
