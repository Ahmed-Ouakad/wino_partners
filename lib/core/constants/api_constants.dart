/// Centralized API endpoint constants.
class ApiConstants {
  /// Base URL for the backend API services.
  /// Configure this with your actual server host (e.g., http://10.0.2.2:8000 for Android emulator).
  static const String baseUrl = 'http://10.0.2.2:3000';

  /// Endpoint for vendor registration
  static const String registerVendorEndpoint = '/auth/register/vendor';

  /// Endpoint for vendor login
  static const String loginVendorEndpoint = '/auth/login/vendor';

  ///Endpoint for listing service categories
  static const String serviceCategoriesEndpoint = '/v1/service-categories';

  /// Endpoint for refreshing authentication tokens
  static const String refreshTokenEndpoint = '/auth/refresh';

  /// Endpoint for creating service availability schedule
  static String serviceAvailabilityEndpoint(String serviceId) =>
      '/v1/vendor/services/$serviceId/availability';

  /// Endpoint for creating vendor addresses
  static const String vendorAddressesEndpoint = '/v1/vendor/addresses';

  /// Endpoint for fetching sub-categories for a service
  static String serviceSubCategoriesEndpoint(String serviceId) =>
      '/v1/service-categories/services/$serviceId/sub-categories';

  /// Endpoint for creating a new sub-category under a category
  static String createSubCategoryEndpoint(String categoryId) =>
      '/v1/service-categories/$categoryId/sub-categories';

  /// Endpoint for generating storage upload URL
  static const String storageUploadUrlEndpoint = '/v1/storage/upload-url';

  /// Endpoint for creating vendor products
  static const String vendorProductsEndpoint = '/v1/vendor/products';

  /// Endpoint for updating and deleting a vendor product by ID
  static String vendorProductDetailEndpoint(String id) =>
      '/v1/vendor/products/$id';

  /// Endpoint for creating and managing vendor posts / reels / stories
  static const String vendorPostsEndpoint = '/v1/vendor/posts';

  /// Endpoint for deleting and retrieving a specific vendor post by ID
  static String vendorPostDetailEndpoint(String id) =>
      '/v1/vendor/posts/$id';

  /// Endpoint for fetching full vendor profile
  static const String vendorProfileEndpoint = '/v1/vendor/profile';

  /// Endpoint for updating current user profile
  static const String usersMeEndpoint = '/v1/users/me';

  /// Endpoint for updating user password
  static const String updatePasswordEndpoint = '/users/me/password';

  /// Endpoint for updating a vendor service by ID
  static String vendorServiceDetailEndpoint(String id) =>
      '/v1/vendor/services/$id';

  /// Endpoint for updating a vendor address by ID
  static String vendorAddressDetailEndpoint(String id) =>
      '/v1/vendor/addresses/$id';

  /// Endpoint for fetching and creating user profile pictures
  static const String userProfilePicturesEndpoint =
      '/v1/users/me/profile-pictures';

  /// Endpoint for activating a specific profile picture
  static String activateProfilePictureEndpoint(String id) =>
      '/v1/users/me/profile-pictures/$id/activate';

  /// Endpoint for deleting a specific profile picture
  static String deleteProfilePictureEndpoint(String id) =>
      '/v1/users/me/profile-pictures/$id';
}
