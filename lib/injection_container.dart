import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/authenticated_http_client.dart';
import 'core/services/caching_service.dart';
import 'core/services/secure_caching_service.dart';
import 'feature/auth/data/datasources/auth_remote_data_source.dart';
import 'feature/auth/data/repositories/auth_repository_impl.dart';
import 'feature/auth/domain/repositories/auth_repository.dart';
import 'feature/auth/domain/usecases/login_vendor_usecase.dart';
import 'feature/auth/domain/usecases/register_vendor_usecase.dart';
import 'feature/auth/presentation/bloc/login_bloc.dart';
import 'feature/auth/presentation/bloc/register_bloc.dart';
import 'feature/location/data/datasources/location_remote_data_source.dart';
import 'feature/location/data/repositories/location_repository_impl.dart';
import 'feature/location/domain/repositories/location_repository.dart';
import 'feature/location/domain/usecases/get_city_suggestions.dart';
import 'feature/location/domain/usecases/get_current_location.dart';
import 'feature/location/domain/usecases/get_saved_location_coordinates.dart';
import 'feature/location/domain/usecases/save_location_coordinates.dart';
import 'feature/location/domain/usecases/search_for_city_coordinates.dart';
import 'feature/location/domain/usecases/update_location_coordinates.dart';
import 'feature/location/presentation/bloc/location_bloc.dart';
import 'feature/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'feature/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'feature/onboarding/domain/repositories/onboarding_repository.dart';
import 'feature/onboarding/domain/usecases/get_service_categories_usecase.dart';
import 'feature/onboarding/domain/usecases/submit_onboarding_usecase.dart';
import 'feature/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'feature/post/data/datasources/post_remote_data_source.dart';
import 'feature/post/data/repositories/post_repository_impl.dart';
import 'feature/post/domain/repositories/post_repository.dart';
import 'feature/post/domain/usecases/create_post_usecase.dart';
import 'feature/post/domain/usecases/delete_post_usecase.dart';
import 'feature/post/domain/usecases/get_post_upload_url_usecase.dart';
import 'feature/post/domain/usecases/get_vendor_posts_usecase.dart';
import 'feature/post/domain/usecases/upload_post_file_usecase.dart';
import 'feature/post/presentation/bloc/create_reel_bloc.dart';
import 'feature/post/presentation/bloc/post_list_bloc.dart';
import 'feature/product/data/datasources/product_remote_data_source.dart';
import 'feature/product/data/repositories/product_repository_impl.dart';
import 'feature/product/domain/repositories/product_repository.dart';
import 'feature/product/domain/usecases/create_product_usecase.dart';
import 'feature/product/domain/usecases/create_sub_category_usecase.dart';
import 'feature/product/domain/usecases/delete_product_usecase.dart';
import 'feature/product/domain/usecases/get_sub_categories_usecase.dart';
import 'feature/product/domain/usecases/get_upload_url_usecase.dart';
import 'feature/product/domain/usecases/get_vendor_products_usecase.dart';
import 'feature/product/domain/usecases/update_product_usecase.dart';
import 'feature/product/domain/usecases/upload_file_usecase.dart';
import 'feature/product/presentation/bloc/add_product_bloc.dart';
import 'feature/product/presentation/bloc/edit_product_bloc.dart';
import 'feature/product/presentation/bloc/product_list_bloc.dart';
import 'feature/profile/data/datasources/profile_remote_data_source.dart';
import 'feature/profile/data/repositories/profile_repository_impl.dart';
import 'feature/profile/domain/repositories/profile_repository.dart';
import 'feature/profile/domain/usecases/activate_profile_picture_usecase.dart';
import 'feature/profile/domain/usecases/add_profile_picture_usecase.dart';
import 'feature/profile/domain/usecases/delete_profile_picture_usecase.dart';
import 'feature/profile/domain/usecases/get_profile_pictures_usecase.dart';
import 'feature/profile/domain/usecases/get_user_profile_usecase.dart';
import 'feature/profile/domain/usecases/update_business_service_usecase.dart';
import 'feature/profile/domain/usecases/update_password_usecase.dart';
import 'feature/profile/domain/usecases/update_user_profile_usecase.dart';
import 'feature/profile/presentation/bloc/profile_bloc.dart';
import 'feature/schedule/data/datasources/schedule_remote_data_source.dart';
import 'feature/schedule/data/repositories/schedule_repository_impl.dart';
import 'feature/schedule/domain/repositories/schedule_repository.dart';
import 'feature/schedule/domain/usecases/submit_schedule_usecase.dart';
import 'feature/schedule/domain/usecases/update_schedule_usecase.dart';
import 'feature/schedule/presentation/bloc/schedule_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes and registers all application dependencies with [GetIt].
Future<void> init() async {
  //! External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  //! Core / Services
  sl.registerLazySingleton<CachingService>(
    () => CachingServiceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<SecureCachingService>(
    () => SecureCachingServiceImpl(secureStorage: sl()),
  );

  sl.registerLazySingleton<AuthenticatedHttpClient>(
    () => AuthenticatedHttpClient(
      innerClient: sl<http.Client>(),
      secureCachingService: sl<SecureCachingService>(),
    ),
  );

  //! 1. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl<AuthenticatedHttpClient>()),
  );
  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(
      client: sl<AuthenticatedHttpClient>(),
      secureCachingService: sl(),
      cachingService: sl(),
    ),
  );
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(
      client: sl<AuthenticatedHttpClient>(),
      secureCachingService: sl(),
    ),
  );
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(
      client: sl<AuthenticatedHttpClient>(),
      secureCachingService: sl(),
    ),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      client: sl<AuthenticatedHttpClient>(),
      rawHttpClient: sl<http.Client>(),
      secureCachingService: sl(),
    ),
  );
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(
      client: sl<AuthenticatedHttpClient>(),
      rawHttpClient: sl<http.Client>(),
      secureCachingService: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      client: sl<AuthenticatedHttpClient>(),
      secureCachingService: sl(),
    ),
  );

  //! 2. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureCachingService: sl(),
    ),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      cachingService: sl(),
      remoteDataSource: sl(),
      client: sl<http.Client>(),
    ),
  );
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      cachingService: sl(),
    ),
  );

  //! 3. Use Cases
  sl.registerLazySingleton<RegisterVendorUseCase>(
    () => RegisterVendorUseCase(sl()),
  );
  sl.registerLazySingleton<LoginVendorUseCase>(
    () => LoginVendorUseCase(sl()),
  );
  sl.registerLazySingleton<GetServiceCategoriesUseCase>(
    () => GetServiceCategoriesUseCase(sl()),
  );
  sl.registerLazySingleton<SubmitOnboardingUseCase>(
    () => SubmitOnboardingUseCase(sl()),
  );
  sl.registerLazySingleton<GetCurrentLocation>(
    () => GetCurrentLocation(sl()),
  );
  sl.registerLazySingleton<SearchForCityCoordinates>(
    () => SearchForCityCoordinates(sl()),
  );
  sl.registerLazySingleton<SaveLocationCoordinates>(
    () => SaveLocationCoordinates(sl()),
  );
  sl.registerLazySingleton<UpdateLocationCoordinates>(
    () => UpdateLocationCoordinates(sl()),
  );
  sl.registerLazySingleton<GetCitySuggestions>(
    () => GetCitySuggestions(sl()),
  );
  sl.registerLazySingleton<GetSavedLocationCoordinates>(
    () => GetSavedLocationCoordinates(sl()),
  );
  sl.registerLazySingleton<SubmitScheduleUseCase>(
    () => SubmitScheduleUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateScheduleUseCase>(
    () => UpdateScheduleUseCase(sl()),
  );
  sl.registerLazySingleton<GetSubCategoriesUseCase>(
    () => GetSubCategoriesUseCase(sl()),
  );
  sl.registerLazySingleton<CreateSubCategoryUseCase>(
    () => CreateSubCategoryUseCase(sl()),
  );
  sl.registerLazySingleton<GetUploadUrlUseCase>(
    () => GetUploadUrlUseCase(sl()),
  );
  sl.registerLazySingleton<UploadFileUseCase>(
    () => UploadFileUseCase(sl()),
  );
  sl.registerLazySingleton<CreateProductUseCase>(
    () => CreateProductUseCase(sl()),
  );
  sl.registerLazySingleton<GetVendorProductsUseCase>(
    () => GetVendorProductsUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(sl()),
  );
  sl.registerLazySingleton<CreatePostUseCase>(
    () => CreatePostUseCase(sl()),
  );
  sl.registerLazySingleton<GetPostUploadUrlUseCase>(
    () => GetPostUploadUrlUseCase(sl()),
  );
  sl.registerLazySingleton<UploadPostFileUseCase>(
    () => UploadPostFileUseCase(sl()),
  );
  sl.registerLazySingleton<GetVendorPostsUseCase>(
    () => GetVendorPostsUseCase(sl()),
  );
  sl.registerLazySingleton<DeletePostUseCase>(
    () => DeletePostUseCase(sl()),
  );
  sl.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(sl()),
  );
  sl.registerLazySingleton<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateBusinessServiceUseCase>(
    () => UpdateBusinessServiceUseCase(sl()),
  );
  sl.registerLazySingleton<GetProfilePicturesUseCase>(
    () => GetProfilePicturesUseCase(sl()),
  );
  sl.registerLazySingleton<AddProfilePictureUseCase>(
    () => AddProfilePictureUseCase(sl()),
  );
  sl.registerLazySingleton<ActivateProfilePictureUseCase>(
    () => ActivateProfilePictureUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteProfilePictureUseCase>(
    () => DeleteProfilePictureUseCase(sl()),
  );

  //! 4. BLoC (Presentation)
  sl.registerFactory<RegisterBloc>(
    () => RegisterBloc(registerVendorUseCase: sl()),
  );
  sl.registerFactory<LoginBloc>(
    () => LoginBloc(loginVendorUseCase: sl()),
  );
  sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      getServiceCategoriesUseCase: sl(),
      submitOnboardingUseCase: sl(),
    ),
  );
  sl.registerFactory<LocationBloc>(
    () => LocationBloc(
      getCurrentLocation: sl(),
      searchForCityCoordinates: sl(),
      saveLocationCoordinates: sl(),
      updateLocationCoordinates: sl(),
      getCitySuggestions: sl(),
      getSavedLocation: sl(),
    ),
  );
  sl.registerFactory<ScheduleBloc>(
    () => ScheduleBloc(
      submitScheduleUseCase: sl(),
      updateScheduleUseCase: sl(),
      cachingService: sl(),
    ),
  );
  sl.registerFactory<AddProductBloc>(
    () => AddProductBloc(
      getSubCategoriesUseCase: sl(),
      createSubCategoryUseCase: sl(),
      getUploadUrlUseCase: sl(),
      uploadFileUseCase: sl(),
      createProductUseCase: sl(),
      cachingService: sl(),
    ),
  );
  sl.registerFactory<ProductListBloc>(
    () => ProductListBloc(
      getVendorProductsUseCase: sl(),
    ),
  );
  sl.registerFactory<EditProductBloc>(
    () => EditProductBloc(
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      getUploadUrlUseCase: sl(),
      uploadFileUseCase: sl(),
    ),
  );
  sl.registerFactory<CreateReelBloc>(
    () => CreateReelBloc(
      createPostUseCase: sl(),
      getUploadUrlUseCase: sl(),
      uploadFileUseCase: sl(),
    ),
  );
  sl.registerFactory<PostListBloc>(
    () => PostListBloc(
      getVendorPostsUseCase: sl(),
      deletePostUseCase: sl(),
    ),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
      updatePasswordUseCase: sl(),
      updateBusinessServiceUseCase: sl(),
      getProfilePicturesUseCase: sl(),
      addProfilePictureUseCase: sl(),
      activateProfilePictureUseCase: sl(),
      deleteProfilePictureUseCase: sl(),
      getUploadUrlUseCase: sl(),
      uploadFileUseCase: sl(),
      cachingService: sl(),
      secureCachingService: sl(),
    ),
  );
}
