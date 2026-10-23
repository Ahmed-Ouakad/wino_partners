import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/core/services/caching_service.dart';
import 'package:wino_partners/core/services/secure_caching_service.dart';
import 'package:wino_partners/feature/profile/data/models/profile_picture_model.dart';
import 'package:wino_partners/feature/profile/data/models/user_profile_model.dart';
import 'package:wino_partners/feature/profile/domain/entities/profile_picture.dart';
import 'package:wino_partners/feature/profile/domain/entities/user_profile.dart';
import 'package:wino_partners/feature/profile/domain/repositories/profile_repository.dart';
import 'package:wino_partners/feature/profile/domain/usecases/activate_profile_picture_usecase.dart';
import 'package:wino_partners/feature/profile/domain/usecases/add_profile_picture_usecase.dart';
import 'package:wino_partners/feature/profile/domain/usecases/delete_profile_picture_usecase.dart';
import 'package:wino_partners/feature/profile/domain/usecases/get_profile_pictures_usecase.dart';
import 'package:wino_partners/feature/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:wino_partners/feature/profile/domain/usecases/update_business_service_usecase.dart';
import 'package:wino_partners/feature/profile/domain/usecases/update_password_usecase.dart';
import 'package:wino_partners/feature/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:wino_partners/feature/profile/presentation/bloc/profile_bloc.dart';
import 'package:wino_partners/feature/profile/presentation/bloc/profile_event.dart';
import 'package:wino_partners/feature/profile/presentation/bloc/profile_state.dart';

class MockCachingService implements CachingService {
  final Map<String, dynamic> storage = {};

  @override
  Future<void> clear() async => storage.clear();

  @override
  double? getDouble(String key) => storage[key] as double?;

  @override
  String? getString(String key) => storage[key] as String?;

  @override
  Future<void> remove(String key) async => storage.remove(key);

  @override
  Future<void> saveDouble(String key, double value) async => storage[key] = value;

  @override
  Future<void> saveString(String key, String value) async => storage[key] = value;
}

class MockSecureCachingService implements SecureCachingService {
  final Map<String, String> secureStorage = {};

  @override
  Future<void> clearAll() async => secureStorage.clear();

  @override
  Future<String?> getAccessToken() async => secureStorage['access_token'];

  @override
  Future<String?> getRefreshToken() async => secureStorage['refresh_token'];

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    secureStorage['access_token'] = accessToken;
    secureStorage['refresh_token'] = refreshToken;
  }
}

class MockProfileRepository implements ProfileRepository {
  UserProfile userProfile = const UserProfile(
    id: 'user_1',
    email: 'vendor@wino.com',
    fullname: 'Test Vendor',
    phoneNumber: '+21699999999',
    role: 'VENDOR',
  );

  List<ProfilePicture> pictures = [
    const ProfilePicture(
      id: 'pic_1',
      mediaUrl: 'https://example.com/pic1.jpg',
      isActive: true,
    ),
    const ProfilePicture(
      id: 'pic_2',
      mediaUrl: 'https://example.com/pic2.jpg',
      isActive: false,
    ),
  ];

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    return Right(userProfile);
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required String fullname,
    required String phoneNumber,
  }) async {
    userProfile = userProfile.copyWith(fullname: fullname, phoneNumber: phoneNumber);
    return Right(userProfile);
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateBusinessService({
    required String serviceId,
    required String title,
    required String description,
    required String categoryId,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<ProfilePicture>>> getProfilePictures() async {
    return Right(pictures);
  }

  @override
  Future<Either<Failure, ProfilePicture>> addProfilePicture(String mediaUrl) async {
    final newPic = ProfilePicture(
      id: 'pic_${pictures.length + 1}',
      mediaUrl: mediaUrl,
      isActive: false,
    );
    pictures.add(newPic);
    return Right(newPic);
  }

  @override
  Future<Either<Failure, void>> activateProfilePicture(String id) async {
    pictures = pictures.map((p) => p.copyWith(isActive: p.id == id)).toList();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteProfilePicture(String id) async {
    pictures.removeWhere((p) => p.id == id);
    return const Right(null);
  }
}

void main() {
  late MockCachingService mockCachingService;
  late MockSecureCachingService mockSecureCachingService;
  late MockProfileRepository mockProfileRepository;
  late ProfileBloc bloc;

  setUp(() {
    mockCachingService = MockCachingService();
    mockSecureCachingService = MockSecureCachingService();
    mockProfileRepository = MockProfileRepository();

    mockCachingService.storage[serviceIdKey] = 'srv_123';
    mockCachingService.storage[businessCategoryIdKey] = 'cat_123';
    mockCachingService.storage[businessTitleKey] = 'Initial Store';
    mockCachingService.storage[businessDescriptionKey] = 'Initial Desc';

    bloc = ProfileBloc(
      getUserProfileUseCase: GetUserProfileUseCase(mockProfileRepository),
      updateUserProfileUseCase: UpdateUserProfileUseCase(mockProfileRepository),
      updatePasswordUseCase: UpdatePasswordUseCase(mockProfileRepository),
      updateBusinessServiceUseCase: UpdateBusinessServiceUseCase(mockProfileRepository),
      getProfilePicturesUseCase: GetProfilePicturesUseCase(mockProfileRepository),
      addProfilePictureUseCase: AddProfilePictureUseCase(mockProfileRepository),
      activateProfilePictureUseCase: ActivateProfilePictureUseCase(mockProfileRepository),
      deleteProfilePictureUseCase: DeleteProfilePictureUseCase(mockProfileRepository),
      cachingService: mockCachingService,
      secureCachingService: mockSecureCachingService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('LoadProfileEvent loads cached values and emits UserProfile successfully', () async {
    final expected = [
      isA<ProfileState>()
          .having((s) => s.businessTitle, 'businessTitle', 'Initial Store')
          .having((s) => s.businessDescription, 'businessDescription', 'Initial Desc'),
      isA<ProfileState>().having((s) => s.isLoading, 'isLoading', true),
      isA<ProfileState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.userProfile?.fullname, 'fullname', 'Test Vendor')
          .having((s) => s.userProfile?.email, 'email', 'vendor@wino.com'),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(const LoadProfileEvent());
  });

  test('UpdateProfileInfoEvent updates user profile info and emits success', () async {
    final expected = [
      isA<ProfileState>().having((s) => s.isUpdatingProfile, 'isUpdatingProfile', true),
      isA<ProfileState>()
          .having((s) => s.isUpdatingProfile, 'isUpdatingProfile', false)
          .having((s) => s.userProfile?.fullname, 'fullname', 'Updated Vendor Name')
          .having((s) => s.userProfile?.phoneNumber, 'phoneNumber', '+21611111111')
          .having((s) => s.successMessage, 'successMessage', contains('succès')),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(const UpdateProfileInfoEvent(
      fullname: 'Updated Vendor Name',
      phoneNumber: '+21611111111',
    ));
  });

  test('ChangePasswordEvent emits successMessage upon successful password update', () async {
    final expected = [
      isA<ProfileState>().having((s) => s.isUpdatingPassword, 'isUpdatingPassword', true),
      isA<ProfileState>()
          .having((s) => s.isUpdatingPassword, 'isUpdatingPassword', false)
          .having((s) => s.successMessage, 'successMessage', contains('succès')),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(const ChangePasswordEvent(
      currentPassword: 'OldPassword123',
      newPassword: 'NewPassword123',
    ));
  });

  test('UpdateBusinessInfoEvent updates business title & description', () async {
    final expected = [
      isA<ProfileState>().having((s) => s.isUpdatingBusiness, 'isUpdatingBusiness', true),
      isA<ProfileState>()
          .having((s) => s.isUpdatingBusiness, 'isUpdatingBusiness', false)
          .having((s) => s.businessTitle, 'businessTitle', 'New Business Name')
          .having((s) => s.businessDescription, 'businessDescription', 'New Business Description')
          .having((s) => s.successMessage, 'successMessage', contains('succès')),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(const UpdateBusinessInfoEvent(
      title: 'New Business Name',
      description: 'New Business Description',
    ));
  });

  test('LogoutEvent clears storage and sets isLoggedOut to true', () async {
    mockSecureCachingService.secureStorage['access_token'] = 'token_abc';
    expectLater(
      bloc.stream,
      emitsInOrder([
        isA<ProfileState>().having((s) => s.isLoggedOut, 'isLoggedOut', true),
      ]),
    );

    bloc.add(const LogoutEvent());
    await pumpEventQueue();

    expect(mockSecureCachingService.secureStorage, isEmpty);
    expect(mockCachingService.storage, isEmpty);
  });

  test('UserProfileModel.fromJson correctly parses /v1/vendor/profile response payload', () {
    final sampleJson = {
      'id': '919cfc97-ed4a-4134-b8f9-a94b05e2a04b',
      'user_id': 'fb0ee2a0-99fa-4e2a-9709-97af6fd6291a',
      'vendor_type': 'PERSONAL',
      'is_available': false,
      'is_validated': false,
      'createdAt': '2026-10-20T13:49:06.796Z',
      'updatedAt': '2026-10-20T13:49:06.796Z',
      'services': [
        {
          'id': '47a48316-9b42-4be8-938e-c300c55875ae',
          'title': 'Supermarchés',
          'description': 'Découvrez un large choix de produits frais...',
          'vendor_profile_id': '919cfc97-ed4a-4134-b8f9-a94b05e2a04b',
          'category_id': 'f2105b3b-cfb7-462c-ae12-50b76d96937d',
        }
      ],
      'addresses': [
        {
          'id': 'c224ca74-4eee-495d-b9f5-58a65ef75bef',
          'title': 'adresse principale',
          'street': 'حي المالوف, الكرنيش...',
          'latitude': 37.29885840303036,
          'longitude': 9.86107026285291,
          'vendor_profile_id': '919cfc97-ed4a-4134-b8f9-a94b05e2a04b',
        }
      ],
      'promos': [],
      'user': {
        'id': 'fb0ee2a0-99fa-4e2a-9709-97af6fd6291a',
        'fullname': 'Mohamed Ben Ali',
        'email': 'vendor@example.com',
        'phone_number': '+21698765111',
      }
    };

    final model = UserProfileModel.fromJson(sampleJson);

    expect(model.id, 'fb0ee2a0-99fa-4e2a-9709-97af6fd6291a');
    expect(model.fullname, 'Mohamed Ben Ali');
    expect(model.email, 'vendor@example.com');
    expect(model.phoneNumber, '+21698765111');
    expect(model.vendorProfileId, '919cfc97-ed4a-4134-b8f9-a94b05e2a04b');
    expect(model.vendorType, 'PERSONAL');
    expect(model.isAvailable, false);
    expect(model.serviceId, '47a48316-9b42-4be8-938e-c300c55875ae');
    expect(model.businessTitle, 'Supermarchés');
    expect(model.categoryId, 'f2105b3b-cfb7-462c-ae12-50b76d96937d');
    expect(model.addressId, 'c224ca74-4eee-495d-b9f5-58a65ef75bef');
    expect(model.addressTitle, 'adresse principale');
    expect(model.addressStreet, 'حي المالوف, الكرنيش...');
    expect(model.latitude, 37.29885840303036);
    expect(model.longitude, 9.86107026285291);
  });

  test('LoadProfilePicturesEvent fetches and emits profile pictures', () async {
    final expected = [
      isA<ProfileState>().having((s) => s.profilePictures.length, 'length', 2),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(const LoadProfilePicturesEvent());
  });

  test('ProfileState.activeProfilePicture returns active picture or fallback', () {
    const p1 = ProfilePicture(id: '1', mediaUrl: 'https://example.com/1.jpg', isActive: false);
    const p2 = ProfilePicture(id: '2', mediaUrl: 'https://example.com/2.jpg', isActive: true);

    const stateWithActive = ProfileState(profilePictures: [p1, p2]);
    expect(stateWithActive.activeProfilePicture?.id, '2');

    const stateWithoutActive = ProfileState(profilePictures: [p1]);
    expect(stateWithoutActive.activeProfilePicture?.id, '1');

    const emptyState = ProfileState(profilePictures: []);
    expect(emptyState.activeProfilePicture, isNull);
  });

  test('ActivateProfilePictureEvent activates picture and emits success message', () async {
    bloc.add(const LoadProfilePicturesEvent());
    await pumpEventQueue();

    final expected = [
      isA<ProfileState>().having((s) => s.isManagingPicture, 'isManagingPicture', true),
      isA<ProfileState>()
          .having((s) => s.isManagingPicture, 'isManagingPicture', false)
          .having((s) => s.successMessage, 'successMessage', contains('activée'))
          .having((s) => s.profilePictures.firstWhere((p) => p.id == 'pic_2').isActive, 'pic_2 active', true),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(const ActivateProfilePictureEvent('pic_2'));
  });

  test('DeleteProfilePictureEvent deletes picture and emits success message', () async {
    bloc.add(const LoadProfilePicturesEvent());
    await pumpEventQueue();

    final expected = [
      isA<ProfileState>().having((s) => s.isManagingPicture, 'isManagingPicture', true),
      isA<ProfileState>()
          .having((s) => s.isManagingPicture, 'isManagingPicture', false)
          .having((s) => s.successMessage, 'successMessage', contains('supprimée'))
          .having((s) => s.profilePictures.length, 'length', 1),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));
    bloc.add(const DeleteProfilePictureEvent('pic_1'));
  });

  test('ProfilePictureModel.fromJson parses both camelCase and snake_case keys correctly', () {
    final jsonCamel = {
      'id': 'pic_10',
      'mediaUrl': 'https://storage.supabase.co/avatars/user-10.jpg',
      'isActive': true,
      'userId': 'usr_1',
      'createdAt': '2026-10-23T10:00:00Z',
    };

    final model1 = ProfilePictureModel.fromJson(jsonCamel);
    expect(model1.id, 'pic_10');
    expect(model1.mediaUrl, 'https://storage.supabase.co/avatars/user-10.jpg');
    expect(model1.isActive, true);
    expect(model1.userId, 'usr_1');

    final jsonSnake = {
      '_id': 'pic_20',
      'media_url': 'https://storage.supabase.co/avatars/user-20.jpg',
      'is_active': false,
      'user_id': 'usr_2',
      'created_at': '2026-10-23T11:00:00Z',
    };

    final model2 = ProfilePictureModel.fromJson(jsonSnake);
    expect(model2.id, 'pic_20');
    expect(model2.mediaUrl, 'https://storage.supabase.co/avatars/user-20.jpg');
    expect(model2.isActive, false);
    expect(model2.userId, 'usr_2');
  });
}

