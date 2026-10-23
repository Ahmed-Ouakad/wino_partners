# Wino Partners - Project Context & Roadmap

> **Notice to AI Agents:** Read this document at the beginning of each session to understand the purpose of the application, target audience, architectural patterns, and current implementation progress. After completing any task, update the **Progress Log** at the bottom of this document with a concise summary of the changes made.

---

## 1. Project Vision & Purpose

**Wino Partners** is a dedicated mobile application for vendors (businesses, individual professionals, and in the future, doctors/practitioners). 

The app allows merchants to set up and manage a **virtual store** where they organize and showcase their products/services, enabling end-users to browse and place orders through a separate client-facing application.

### Key Capabilities for Vendors:
- **Store Setup & Identity:** Define business category, detailed store description, physical addresses/locations, and operating schedules (opening and closing hours).
- **Product & Catalog Management:** Add and organize products by categories/sub-categories, and showcase them with photos and promotional videos.
- **Promotions & Offers:** Create and manage special promotions/discounts for clients.
- **Order Management:** View incoming client orders in real time and react accordingly (confirm/fulfill orders or decline if stock is insufficient).
- **Analytics & Dashboard:** Track key performance indicators (views on product videos, order volumes, revenue metrics).

---

## 2. Architecture & Technical Guidelines

- **Architecture:** Clean Architecture (`data`, `domain`, `presentation`) per feature module.
  - `data`: Models, Data Sources (remote API with `http`), and Repository Implementations.
  - `domain`: Entities, Repository Contracts, and Use Cases with `dartz` (`Either<Failure, T>`).
  - `presentation`: BLoC (`flutter_bloc`), Screens, and Widgets.
- **Dependency Injection:** Centralized via `GetIt` in [`lib/injection_container.dart`](file:///c:/Users/SKYMIL/AndroidStudioProjects/wino_partners/lib/injection_container.dart).
- **Design System:** Consistent color scheme (`primary`: `#C61D23`, `secondary`: `#86AB3E`), custom input styling, responsive layout, dark/light theme support.
- **Security & Caching:** Sensitive auth tokens managed securely with `flutter_secure_storage` via `SecureCachingService`.

---

## 3. Current Project State

| Module / Feature | Status | Notes |
| :--- | :--- | :--- |
| **Authentication** | ✅ Completed | Login and Signup screens with BLoC, remote data source, token caching, and input validation. |
| **Onboarding (Part 1)** | ✅ Completed | Category selection (dynamic fetch from `GET /v1/service-categories`) and client-facing business description form with BLoC. |
| **Dashboard / Main Screen** | 🟡 UI Only | Home dashboard layout, bottom navigation, and metrics UI built; backend integration & business logic pending. |
| **Location / Store Address** | ✅ Completed | LocationPickerScreen with FlutterMap, OSM tiles, Nominatim search, Geolocator GPS, local caching, and backend address submission (`POST /v1/vendor/addresses`). |
| **Store Schedule** | ✅ Completed | Weekly operating hours with same-day sync and backend availability API (`POST /v1/vendor/services/{service_id}/availabilty`). |
| **Product & Media Management**| ✅ Completed | Products catalog, CRUD, and Reel/Video publishing workflow via Supabase storage & vendor posts endpoint. |
| **Vendor Profile & Settings** | ✅ Completed | Full profile management (Personal info, Password change, Business details, Location update via PATCH, Schedule update via PUT array, Logout). |
| **Order Management** | ⏳ Pending | Real-time order list, accept/reject order actions. |
| **Promotions** | ⏳ Pending | Discount and promo creation. |

---

## 4. Progress Log & Completed Tasks

*(Agents: Append a new entry here whenever a task is completed.)*

### [2026-10-20] - Onboarding (Part 1: Category & Description)
- **Feature:** Created the complete `lib/feature/onboarding/` Clean Architecture module.
- **Data Layer:** 
  - `OnboardingRemoteDataSource`: Fetches service categories via `GET /v1/service-categories` (with bearer token support) and submits onboarding parameters.
  - `ServiceCategoryModel`: Resilient JSON serialization for category IDs, titles, and subcategories.
  - `OnboardingRepositoryImpl`: Error handling mapping to `ServerFailure` and `NetworkFailure`.
- **Domain Layer:** 
  - `ServiceCategory` and `OnboardingParams` entities.
  - `GetServiceCategoriesUseCase` and `SubmitOnboardingUseCase`.
- **Presentation Layer:**
  - `OnboardingBloc`, events, and state management.
  - `OnboardingScreen`: Dynamic dropdown loading categories from the server with error/retry handling, multiline business description field, and theme-consistent styling.
- **DI & Setup:** Registered all dependencies in `injection_container.dart` and provided `OnboardingBloc` in `main.dart`.
- **Project Governance:** Created `rules.md` and `project_context.md` for AI agent instructions and communication protocol.

### [2026-10-20] - Automatic JWT Token Refresh Mechanism
- **Core Network Layer:** Created `AuthenticatedHttpClient` extending `http.BaseClient` (`lib/core/network/authenticated_http_client.dart`).
- **Authorization Interception:** Automatically injects `Authorization: Bearer <access_token>` from `SecureCachingService` into outgoing requests.
- **401 Interception & Auto-Refresh:** Catches 401 Unauthorized responses, triggers `_refreshToken()` using the stored refresh token on `/auth/refresh`, persists updated tokens via `SecureCachingService.saveTokens()`, and seamlessly retries the request.
- **Race Condition Prevention:** Implemented a deduplication future (`_refreshFuture`) so multiple simultaneous 401s coalesce into a single refresh request.
- **Session Expiry Handling:** Clears secure storage (`clearAll()`) and raises `SessionExpiredException` if refresh fails or tokens are invalid.
- **Request Cloning:** Added `_cloneRequest()` supporting `http.Request`, `http.MultipartRequest`, and base requests to preserve headers and body bytes for replay.
- **Dependency Injection:** Registered `AuthenticatedHttpClient` in `injection_container.dart` and injected it into `AuthRemoteDataSourceImpl` and `OnboardingRemoteDataSourceImpl`.

### [2026-10-20] - Signup Token Persistence & `has_service` Redirection
- **Token Persistence on Signup:** Added token caching logic to `AuthRepositoryImpl.registerVendor` matching `loginVendor`. Newly registered users now have their `access_token` and `refresh_token` securely stored in `SecureCachingService`.
- **Payload & Model Integration:** Created `AuthResponse` entity and `AuthResponseModel` supporting `{ access_token, refresh_token, has_service }` from both login and signup responses.
- **Dynamic Post-Auth Routing:** Updated `RegisterSuccess` and `LoginSuccess` states to convey `hasService: bool`.
- **Screen Redirection (`has_service` check):** In both `SignupScreen` and `LoginScreen`, if `has_service == false`, the user is immediately routed to `OnboardingScreen` to complete their virtual storefront profile. If `has_service == true`, they are routed directly to `MainScreen`.

### [2026-10-20] - Business Location Picker Screen
- **Feature Module:** Created `lib/feature/location/` following Clean Architecture (`data`, `domain`, `presentation`).
- **Domain Layer:** 
  - `LocationCoordinate` and `CitySuggestion` entities.
  - `LocationRepository` interface.
  - Use cases: `GetCurrentLocation`, `SearchForCityCoordinates`, `SaveLocationCoordinates`, `GetCitySuggestions`, `GetSavedLocationCoordinates`.
- **Data Layer:** 
  - `LocationRepositoryImpl`: Integrates `geolocator` for device GPS, Nominatim (OpenStreetMap) for live autocomplete city suggestions & geocoding fallback, and local caching.
- **Core Services & Failures:**
  - Added `CachingService` (`CachingServiceImpl`) backed by `SharedPreferences` for double/string persistence (`latitudeKey`, `longitudeKey`).
  - Added location-specific failure classes to `failures.dart`: `LocationServiceDisabled`, `PermissionFailure`, `NoLocationFailure`, `CacheFailure`.
- **Presentation Layer:**
  - `LocationBloc`, `LocationEvent`, `LocationState`.
  - `LocationPickerScreen`: Interactive OpenStreetMap via `flutter_map` with center pin, city search with 500ms debouncing, live suggestions popup, GPS fab, and coordinates confirmation.
- **Workflow Connection:** Connected navigation so completing `OnboardingScreen` now leads directly to `LocationPickerScreen`, which upon saving location routes to `MainScreen`.
- **Permissions & DI:** Added Android location permissions to `AndroidManifest.xml`, registered all location dependencies in `injection_container.dart`, and provided `LocationBloc` in `main.dart`.
### [2026-10-21] - Store Schedule & Availability (Final Onboarding Step)
- **Feature Module:** Created `lib/feature/schedule/` following Clean Architecture (`data`, `domain`, `presentation`).
- **Domain Layer:**
  - `DaySchedule` entity: represents individual day operating configuration (`dayCode`, `dayName`, `apiDay`, `openTime`, `closeTime`, `isOpen`) with JSON serialization.
  - `ScheduleRepository` contract.
  - `SubmitScheduleUseCase` & `SubmitScheduleParams`.
- **Data Layer:**
  - `ScheduleRemoteDataSource`: Submits active availability schedules one by one via POST to `baseUrl + /v1/vendor/services/{service_id}/availabilty` with `{ day, open_time, close_time }` and Bearer token authorization.
  - `ScheduleRepositoryImpl`: Handles errors and returns `Either<Failure, void>`.
  - Updated `OnboardingRemoteDataSourceImpl` to automatically extract and cache the created `service_id` into `CachingService` upon completing the first onboarding step.
- **Presentation Layer:**
  - `ScheduleBloc`, `ScheduleEvent`, `ScheduleState`:
    - Defaults to Lu-Ve active (`07:00 - 19:00`), Sa-Di inactive.
    - Synchronizes times across all enabled days when `Mêmes horaires chaque jours` toggle is enabled.
    - Manages day open/closed toggles and time picking.
    - Validates cached `service_id` and submits active days sequentially.
  - `DayScheduleRow`: Custom row matching the reference UI with circular day badge (`Lu`, `Ma`, etc.), 24h `TimePicker` trigger on underlined time labels, and active switch.
  - `ScheduleScreen`: Header with circular back button, "Horaires" title, "Mêmes horaires chaque jours" toggle, list of days, and "Continuer" rounded button styled in Wino brand red (`#C61D23`).
- **Navigation & DI:**
  - Routed `LocationPickerScreen` on save directly to `ScheduleScreen`.
  - On schedule submission success, routes to `MainScreen` and clears navigation stack.
### [2026-10-21] - Store Location Backend Address Submission
- **API Endpoint & Contract:** Added `ApiConstants.vendorAddressesEndpoint` (`/v1/vendor/addresses`).
- **Data Layer:**
  - Created `LocationRemoteDataSource` (`LocationRemoteDataSourceImpl`) to POST vendor address to `baseUrl + /v1/vendor/addresses` with `{ title: "adresse principale", street, latitude, longitude }` and Bearer token authentication via `AuthenticatedHttpClient`.
  - Added reverse geocoding via OpenStreetMap Nominatim (`https://nominatim.openstreetmap.org/reverse`) to resolve street address when no text is provided in the search bar (with fallback to default).
  - Updated `LocationRepositoryImpl.saveLocationCoordinates` to both cache coordinates locally (`latitudeKey`, `longitudeKey`) and submit the address payload to the backend.
- **Domain & Presentation Layers:**
  - Updated `LocationRepository` interface and `SaveLocationCoordinates` use case to support optional `street` parameter.
  - Updated `SaveLocationEvent` and `LocationBloc` to receive and pass `street` to `saveLocationCoordinates`.
  - In `LocationPickerScreen`, passing `_searchController.text` as `street` if entered by the user, or delegating to reverse geocoding.
- **DI & Testing:**
  - Registered `LocationRemoteDataSource` in `injection_container.dart` and injected into `LocationRepositoryImpl`.
  - Added unit test suite in `test/feature/location/save_location_test.dart` (3 tests covering cache persistence, street override, reverse geocoding fallback, and BLoC emission). All 14 feature unit tests passing.

### [2026-10-21] - Add Product Flow & Quick Actions Integration
- **Entry Points & Navigation:**
  - Updated `QuickActionsSection` on `HomeScreen`: "Nouveau Produit" button opens `AddProductScreen`.
  - Updated `HomeBottomNavBar` in `MainScreen`: tapping the center red FloatingActionButton opens an animated Quick Actions modal bottom sheet offering the 4 core actions ("Nouveau Produit", "Nouvelle Promo", "Nouveau Reel", "Nouvelle Story"). Selecting "Nouveau Produit" routes directly to `AddProductScreen`.
- **API Endpoints Added (`ApiConstants`):**
  - `serviceSubCategoriesEndpoint(serviceId)`: `GET /v1/service-categories/services/{serviceId}/sub-categories`
  - `createSubCategoryEndpoint(categoryId)`: `POST /v1/service-categories/{categoryId}/sub-categories`
  - `storageUploadUrlEndpoint`: `POST /v1/storage/upload-url`
  - `vendorProductsEndpoint`: `POST /v1/vendor/products`
- **Domain Layer (`lib/feature/product/domain/`):**
  - Entities: `SubCategory`, `ServiceSubCategories`, `UploadUrlResponse`, `CreateProductParams`.
  - Repository interface: `ProductRepository`.
  - Use cases: `GetSubCategoriesUseCase`, `CreateSubCategoryUseCase`, `GetUploadUrlUseCase`, `UploadFileUseCase`, `CreateProductUseCase`.
- **Data Layer (`lib/feature/product/data/`):**
  - Models: `SubCategoryModel`, `ServiceSubCategoriesModel`, `UploadUrlModel`.
  - `ProductRemoteDataSourceImpl`:
    - Handles GET sub-categories with vendor service ID.
    - Handles POST to create a sub-category under the retrieved `categoryId`.
    - Handles POST to `/v1/storage/upload-url` with `{ filename, folder: "products" }`.
    - Handles PUT image binary data to Supabase signed `uploadUrl` using raw client (without backend Bearer token to prevent Supabase rejection).
    - Handles POST to `/v1/vendor/products` with `{ title, price, sub_category_id, description, image_url }`.
  - `ProductRepositoryImpl`: Translates exceptions to standard `Failure` classes.
- **Presentation Layer (`lib/feature/product/presentation/`):**
  - `AddProductBloc`:
    - Loads existing sub-categories and filters suggestions dynamically as user types.
    - Handles image picking from Gallery or Camera using `image_picker`.
    - Orchestrates the full creation pipeline on submit: creates subcategory if new -> requests Supabase signed URL -> uploads image -> creates product on backend.
    - Tracks step-by-step progress status messages for user transparency and error resilience.
  - `AddProductScreen`: Premium UI featuring image picker box with Camera/Gallery bottom sheet, live sub-category autocomplete with popup suggestion list, title, numeric price, description, and "Ajouter le produit" action button with loading indicators and error banners.
- **Dependency Injection & Tests:**
  - Registered all product feature contracts, use cases, and remote data sources in `injection_container.dart`.
  - Provided `AddProductBloc` globally in `main.dart`.
  - Created unit tests in `test/feature/product/add_product_bloc_test.dart` (7 unit tests covering loading, filtering, selection, auto-creation of sub-categories, upload, and validation). All 21 feature unit tests passing with 0 analyzer issues.

### [2026-10-22] - Vendor Product List Screen (Articles)
- **Feature Overview:** Implemented the vendor products screen where articles are fetched from the server and organized by their respective sub-categories.
- **Entry Points & Navigation:**
  - Accessible via the **Articles** tab (index 2) in the bottom navigation bar on `MainScreen`.
  - Added a `+` icon button in primary brand color with a transparent background in the top-right app bar of `ProductListScreen`. Tapping it navigates to `AddProductScreen`, and automatically triggers a list refresh when returning.
- **Data & Domain Layers:**
  - Created domain entities `Product` and `SubCategoryProducts`.
  - Created data models `ProductModel` and `SubCategoryProductsModel` with JSON serialization.
  - Added `getVendorProducts` to `ProductRemoteDataSourceImpl` invoking `GET /v1/vendor/products` with authorization headers.
  - Automatically filters out sub-categories that have no products (`products.isNotEmpty`).
  - Added `GetVendorProductsUseCase` and updated `ProductRepositoryImpl`.
- **Presentation Layer:**
  - Created `ProductListBloc`, `ProductListEvent` (`LoadVendorProductsEvent`, `RefreshVendorProductsEvent`), and `ProductListState`.
  - Built `ProductListScreen`:
    - Top bar with "Articles" title and transparent primary-colored `+` button.
    - Pull-to-refresh (`RefreshIndicator`).
    - Sub-category section headers with product counter badges.
    - Clean product cards displaying network images with shimmers and error fallbacks, product title, description, formatted price (`DT`), and availability status badge ("Disponible" / "Épuisé").
    - Clean empty state illustration with an "Ajouter un produit" shortcut button.
    - Error state with retry action.
- **DI & Tests:**
  - Registered `GetVendorProductsUseCase` and `ProductListBloc` in `injection_container.dart` and provided in `MultiBlocProvider` in `main.dart`.
  - Created unit tests in `test/feature/product/product_list_bloc_test.dart` (6 tests covering model deserialization, state emissions, pull-to-refresh, and error handling).
  - All 27 feature unit tests passing; 0 analyzer warnings.

### [2026-10-22] - Update & Delete Product (Product Details Screen)
- **Feature Overview:** Added full product management capabilities allowing vendors to edit product details (title, price, description, and cover photo) and delete products.
- **Entry Points & Navigation:**
  - Tapping any product card in `ProductListScreen` navigates to `ProductDetailScreen`.
  - On returning from saving changes or deleting the product, the list automatically triggers a refresh.
- **Endpoints & Data Layer:**
  - `PATCH /v1/vendor/products/{id}`: Updates product details with `{ title, price, description, image_url }`.
  - `DELETE /v1/vendor/products/{id}`: Deletes the product by ID.
  - Added `vendorProductDetailEndpoint(id)` in `ApiConstants`.
  - Created `UpdateProductParams` domain entity.
  - Created `UpdateProductUseCase` and `DeleteProductUseCase`.
  - Implemented `updateProduct` and `deleteProduct` in `ProductRemoteDataSourceImpl` and `ProductRepositoryImpl`.
- **Presentation Layer:**
  - Created `EditProductBloc`, `EditProductEvent`, and `EditProductState`.
  - Built `ProductDetailScreen`:
    - Top image preview with "Modifier la photo" action trigger (modal bottom sheet for Gallery / Camera).
    - Dedicated field cards for Title, Price (DT), and Description, each featuring an explicit "Modifier" button on the left side that activates and focuses the field.
    - Save button styled in `colorScheme.secondary` (Wino green `#86AB3E`), intelligently enabled only when modifications have occurred (`hasChanges == true`).
    - Delete button in `colorScheme.primary` (Wino red `#C61D23`), triggering a confirmation dialog with warning icon and irreversible action disclaimer.
    - Smooth status banners during image re-upload and backend saving.
- **DI & Testing:**
  - Registered use cases and `EditProductBloc` in `injection_container.dart`.
  - Added unit test suite `test/feature/product/edit_product_bloc_test.dart` (6 unit tests covering initial load, change detection, upload pipeline, update submission, and deletion).
  - All 33 feature unit tests passing; 0 analyzer warnings.

### [2026-10-22] - Nouveau Reel (Vendor Video Post Creation)
- **Feature Overview:** Implemented the full "Nouveau Reel" flow enabling vendors to record or upload videos, customize title and caption, upload to Supabase storage, and publish posts to `/v1/vendor/posts`.
- **Entry Points & Navigation:**
  - **QuickActionsSection:** "Nouveau Reel" button triggers the source modal (Galerie or Caméra) and opens `CreateReelScreen`.
  - **MainScreen FAB Bottom Sheet:** Center floating action button modal's "Nouveau Reel" item also prompts the source modal and navigates to `CreateReelScreen`.
- **API Endpoints & Infrastructure:**
  - `POST /v1/storage/upload-url`: Requests signed upload URL with `{ filename, folder: "posts" }`.
  - `PUT <uploadUrl>`: Uploads raw video bytes to Supabase storage signed URL using raw HTTP client.
  - `POST /v1/vendor/posts`: Sends post payload:
    ```json
    {
      "media_url": "<publicUrl>",
      "title": "<title>",
      "caption": "<caption>",
      "media_type": "Video",
      "is_story": false
    }
    ```
- **Clean Architecture Implementation (`lib/feature/post/`):**
  - **Domain Layer:** `CreatePostParams` entity, `PostRepository` interface, and use cases `CreatePostUseCase`, `GetPostUploadUrlUseCase`, `UploadPostFileUseCase`.
  - **Data Layer:** `PostRemoteDataSource` (`PostRemoteDataSourceImpl`) and `PostRepositoryImpl` with Bearer token authentication and error mapping.
  - **Presentation Layer:**
    - `CreateReelBloc`, `CreateReelEvent`, and `CreateReelState` handling video picking, input validation, upload progress updates, and submission.
    - `CreateReelScreen`: Video card preview with file details and change/remove actions, title field, caption field, and brand-styled "Publier le réel" button with loading indicator.
- **DI & Testing:**
  - Registered all Post feature dependencies in `injection_container.dart`.
  - Created unit test suite in `test/feature/post/create_reel_bloc_test.dart` (7 tests covering initial state, video selection, input validation, and full upload/publishing pipeline).
  - All 40 unit tests passing; 0 analyzer issues.

### [2026-10-22] - Media Screen & Vendor Posts Listing
- **Feature Overview:** Implemented the Media feature allowing vendors to view and manage all their published posts (Reels, Videos, and Images) grouped by media type, accessible via a dedicated "Média" navigation item in the bottom navbar.
- **Entry Points & Navigation:**
  - **Bottom Navigation Bar (`HomeBottomNavBar`):** Added a new tab named **"Média"** at index 3 (with `Icons.video_library_outlined`), with Profil shifting to index 4.
  - **`MainScreen`:** Mounted `MediaScreen` at index 3 in `_screens`.
  - **App Bar Action (`+` Button):** Added a top-right `+` button in primary color (`#C61D23`) with transparent background to launch `CreateReelScreen.showPickerAndOpen(context)`, automatically refreshing the list upon return.
- **API & Endpoints:**
  - `GET /v1/vendor/posts`: Retrieves vendor media posts with Bearer token authentication.
  - Flexible parsing for fields such as `views_count` / `viewsCount`, `media_url` / `mediaUrl`, `media_type` / `mediaType`, and `is_story`.
- **Clean Architecture Implementation (`lib/feature/post/`):**
  - **Domain Layer:**
    - `Post`: Entity representing vendor post (`id`, `title`, `caption`, `mediaUrl`, `mediaType`, `isStory`, `viewsCount`, `createdAt`, `updatedAt`, `isVideo`, `isImage`).
    - `GroupedPosts`: Entity grouping posts by media type (`mediaType`, `typeTitle`, `posts`).
    - `PostRepository`: Added `getVendorPosts()` contract.
    - `GetVendorPostsUseCase`: Use case invoking repository to retrieve vendor posts.
  - **Data Layer:**
    - `PostModel`: Implements JSON deserialization and serialization with fallback mappings.
    - `PostRemoteDataSourceImpl`: Added `getVendorPosts()` calling `GET /v1/vendor/posts` with Bearer auth headers, request/response logging, and standard error handling.
    - `PostRepositoryImpl`: Implemented `getVendorPosts()` returning `Either<Failure, List<Post>>`.
  - **Presentation Layer:**
    - `PostListBloc`, `PostListEvent` (`LoadVendorPostsEvent`, `RefreshVendorPostsEvent`), and `PostListState` managing loading, refresh, failure, and automatic grouping into `GroupedPosts` (Vidéos & Reels, Images).
    - `MediaScreen`:
      - Header with 'Médias' title and top-right `+` icon button.
      - Pull-to-refresh (`RefreshIndicator`).
      - Group headers displaying type title and count pill.
      - Media post cards with preview thumbnail (video overlay with play badge for videos; network image for images), type tags (Vidéo / Image), Story chip, views count (`X vues`), and publication date.
      - Clean empty state with "Créer un réel" CTA and retryable error state.
- **DI & Testing:**
  - Registered `GetVendorPostsUseCase` and `PostListBloc` in `injection_container.dart`.
  - Provided `PostListBloc` in `MultiBlocProvider` in `main.dart`.
  - Added unit test suite in `test/feature/post/post_list_bloc_test.dart` (6 tests covering model deserialization, JSON serialization, initial state, load success with grouping, load failure, and pull-to-refresh).
  - All 46 feature tests passing; 0 analyzer warnings.

### [2026-10-22] - Full-Screen Media Viewer & Swipe-to-Delete Media
- **Feature Overview:** Added full-screen media viewing for images and videos with playback controls, plus swipe-to-delete with confirmation modal communicating with the backend delete endpoint.
- **Full-Screen Media Viewer (`MediaViewerScreen`):**
  - Tapping any media card in `MediaScreen` launches `MediaViewerScreen(post: post)`.
  - Immersive dark UI (`Colors.black`) with smooth toggleable controls overlay (top navigation bar and bottom caption banner).
  - **Images:** Pinch-to-zoom and pan via `InteractiveViewer`, network loading builder, and failure fallback.
  - **Videos:** Integrated `video_player: ^2.14.1` with auto-play, looping, tap-to-toggle play/pause overlay, scrubber/progress bar with elapsed & remaining duration indicators, and retry mechanism on network playback failure.
  - Quick-action delete button in the top overlay bar allowing immediate deletion with confirmation.
- **Swipe-to-Delete Media Workflow:**
  - Each media card in `MediaScreen` is wrapped with `Dismissible` (`direction: DismissDirection.endToStart`).
  - Swiping reveals a brand-red background with delete icon and "Supprimer" indicator.
  - `confirmDismiss` triggers an alert confirmation dialog:
    - Primary red warning icon.
    - Dialog title: "Supprimer ce média ?".
    - Explanation: "Êtes-vous sûr de vouloir supprimer '{title}' ? Cette action est irréversible."
    - Buttons: "Annuler" and "Supprimer".
  - If confirmed, triggers `DeletePostEvent` calling `DELETE /v1/vendor/posts/{id}`.
  - On success, the post is removed from state, lists & groups recompute dynamically, and a success SnackBar is displayed.
- **API & Endpoints:**
  - `DELETE /v1/vendor/posts/{id}`: Deletes vendor post by ID with Bearer auth header.
  - Added `ApiConstants.vendorPostDetailEndpoint(id)`.
- **Clean Architecture Implementation (`lib/feature/post/`):**
  - **Domain Layer:** `deletePost(String id)` method in `PostRepository`, `DeletePostUseCase`.
  - **Data Layer:** `deletePost(String id)` in `PostRemoteDataSource` & `PostRepositoryImpl`.
  - **Presentation Layer:**
    - `DeletePostEvent` in `PostListEvent`.
    - `deletingPostId` and `actionSuccessMessage` in `PostListState`.
    - `PostListBloc` handling `DeletePostEvent` and updating state.
    - `MediaScreen` with `Dismissible`, `confirmDismiss`, `InkWell` tap handler, and `BlocConsumer` SnackBar notifications.
- **DI & Testing:**
  - Registered `DeletePostUseCase` in `injection_container.dart` and injected into `PostListBloc`.
  - Updated mock repository in `test/feature/post/create_reel_bloc_test.dart` and `test/feature/post/post_list_bloc_test.dart`.
  - Added tests for `DeletePostEvent` (success and error handling).
  - All 48 feature unit tests passing; 0 analyzer issues found.

### [2026-10-23] - Vendor Profile & Settings (Bottom Navigation Tab 4)
- **Feature Overview:** Implemented the complete Clean Architecture **Profil** module (`lib/feature/profile/`) accessible from the bottom navigation bar (Tab 4), enabling vendors to manage personal information, update their password, edit business identity, update store location using the location picker with `PATCH /v1/vendor/addresses/{id}`, update operating hours using `PUT /v1/vendor/services/{serviceId}/availability` with combined availabilities array, and log out safely.
- **Endpoints & API Integration:**
  - `GET /v1/vendor/profile`: Fetches complete vendor profile including user account details (`user.id`, `user.fullname`, `user.email`, `user.phone_number`), vendor metadata (`vendor_type`, `is_available`, `is_validated`), first service details (`services[0].id`, `services[0].title`, `services[0].description`, `services[0].category_id`, `services[0].availabilities`), and first address details (`addresses[0].id`, `addresses[0].title`, `addresses[0].street`, `addresses[0].latitude`, `addresses[0].longitude`).
  - `PATCH /v1/users/me`: Updates personal details with body `{"fullname": "...", "phone_number": "..."}`.
  - `PATCH /users/me/password`: Updates password with body `{"currentPassword": "...", "newPassword": "..."}`.
  - `PATCH /v1/vendor/services/{id}`: Updates business details with body `{"title": "...", "description": "...", "category_id": "..."}`.
  - `PATCH /v1/vendor/addresses/{id}`: Updates store address location with body `{"title": "...", "street": "...", "latitude": ..., "longitude": ...}`.
  - `PUT /v1/vendor/services/{serviceId}/availability`: Updates store schedule by sending combined array of open days: `[{"day": "MONDAY", "open_time": "08:00", "close_time": "23:00"}, ...]`.
- **Address & Location Flow Updates (`lib/feature/location/`):**
  - Updated `saveVendorAddress` in `LocationRemoteDataSource` to parse and extract the address ID returned by the server on initial creation, saving it to `CachingService` (`address_id`, `address_street`, `address_title`).
  - Added `updateVendorAddress` method calling `PATCH /v1/vendor/addresses/{id}`.
  - Added `updateLocationCoordinates` in `LocationRepository` and `LocationRepositoryImpl`.
  - Created `UpdateLocationCoordinates` use case and added `UpdateLocationEvent` in `LocationBloc`.
  - Updated `LocationPickerScreen`:
    - Added `isUpdating` and `addressId` parameters.
    - Added top back button when in update mode.
    - Dynamic button label: `"Mettre à jour l'adresse"` vs `"Confirmer l'emplacement"`.
    - On confirmation in update mode, dispatches `UpdateLocationEvent` and returns `Navigator.pop(context, true)` instead of navigating to onboarding schedule screen.
- **Schedule & Availability Flow Updates (`lib/feature/schedule/`):**
  - Added `updateFullSchedule` in `ScheduleRemoteDataSource` and `ScheduleRemoteDataSourceImpl` executing `PUT /v1/vendor/services/{serviceId}/availability` with the full array of open days.
  - Added `updateSchedule` to `ScheduleRepository` and `ScheduleRepositoryImpl`.
  - Created `UpdateScheduleUseCase` in `lib/feature/schedule/domain/usecases/update_schedule_usecase.dart`.
  - Added `UpdateScheduleEvent` and handler in `ScheduleBloc`.
  - Updated `ScheduleScreen`:
    - Added `isUpdating` parameter.
    - Submit button triggers `UpdateScheduleEvent()` and displays `"Enregistrer les modifications"`.
    - On success, pops the screen with `Navigator.pop(context, true)` instead of replacing routes.
- **Clean Architecture Implementation (`lib/feature/profile/`):**
  - **Domain Layer:**
    - `UserProfile` entity holding user account details (`id`, `email`, `fullname`, `phoneNumber`, `role`), vendor metadata (`vendorProfileId`, `vendorType`, `isAvailable`, `isValidated`), first service details (`serviceId`, `businessTitle`, `businessDescription`, `categoryId`), and first address details (`addressId`, `addressTitle`, `addressStreet`, `latitude`, `longitude`).
    - `ProfileRepository` contract defining `getUserProfile()`, `updateUserProfile()`, `updatePassword()`, and `updateBusinessService()`.
    - Use cases: `GetUserProfileUseCase`, `UpdateUserProfileUseCase`, `UpdatePasswordUseCase`, `UpdateBusinessServiceUseCase`.
  - **Data Layer:**
    - `UserProfileModel` extracting user, first element of `services`, and first element of `addresses`.
    - `ProfileRemoteDataSourceImpl` calling `GET /v1/vendor/profile`, `PATCH /v1/users/me`, `PATCH /users/me/password`, and `PATCH /v1/vendor/services/{id}` with Bearer auth headers, response status checks, and detailed logging.
    - `ProfileRepositoryImpl` synchronizing loaded service and address IDs, titles, descriptions, and coordinates to `CachingService`.
  - **Presentation Layer:**
    - `ProfileBloc`, `ProfileEvent` (`LoadProfileEvent`, `UpdateProfileInfoEvent`, `ChangePasswordEvent`, `UpdateBusinessInfoEvent`, `RefreshCachedDetailsEvent`, `LogoutEvent`), and `ProfileState`.
    - `ProfileScreen`:
      - **Header Card:** Vendor initials avatar, verified badge, full name, email, phone number, and "Modifier profil" button with modal sheet.
      - **Business Info Card:** Shows store title and description with modal sheet to edit title and description.
      - **Store Address Card:** Displays active street and "Modifier l'adresse" button pushing `LocationPickerScreen(isUpdating: true)`.
      - **Operating Hours Card:** Displays active schedule information and "Modifier les horaires" button pushing `ScheduleScreen(isUpdating: true)`.
      - **Security Card:** "Changer mot de passe" button with old password, new password, and confirmation modal.
      - **Logout Button:** Red outlined action with confirmation dialog, clearing `SecureCachingService` and `CachingService` and redirecting to `LoginScreen`.
- **DI & Testing:**
  - Registered all profile components, use cases, repository, and `ProfileBloc` in `lib/injection_container.dart`.
  - Provided `ProfileBloc` in `MultiBlocProvider` in `lib/main.dart`.
  - Integrated `ProfileScreen` into `MainScreen` tab index 4.
  - Created complete unit test suite for `ProfileBloc` and `UserProfileModel.fromJson` in `test/feature/profile/profile_bloc_test.dart`.
  - Ran `flutter test`: all 58 tests passing.
  - Ran `flutter analyze`: 0 issues found.

### [2026-10-23] - Profile Picture Management (Multi-Avatar Upload, Activation & Deletion)
- **Feature Overview:** Comprehensive profile picture management system enabling vendors to upload multiple avatar photos, view them in a gallery modal, activate a selected photo to be displayed as their profile picture, and delete unwanted photos.
- **Endpoints & API Contracts:**
  - `POST /v1/storage/upload-url`: Requests Supabase signed upload URL with `{ filename: "...", folder: "avatars" }`.
  - Raw `PUT` to `uploadUrl`: Uploads image binary data to Supabase storage without backend auth headers.
  - `POST /v1/users/me/profile-pictures`: Associates public URL with the user account with `{ "mediaUrl": "..." }`.
  - `GET /v1/users/me/profile-pictures`: Retrieves all user profile pictures.
  - `PATCH /v1/users/me/profile-pictures/{id}/activate`: Sets the specified photo as active.
  - `DELETE /v1/users/me/profile-pictures/{id}`: Deletes the specified photo.
- **Domain Layer (`lib/feature/profile/domain/`):**
  - Entity: `ProfilePicture` (`id`, `mediaUrl`, `isActive`, `userId`, `createdAt`).
  - Extended `ProfileRepository` interface with `getProfilePictures()`, `addProfilePicture(mediaUrl)`, `activateProfilePicture(id)`, and `deleteProfilePicture(id)`.
  - Added use cases: `GetProfilePicturesUseCase`, `AddProfilePictureUseCase`, `ActivateProfilePictureUseCase`, `DeleteProfilePictureUseCase`.
- **Data Layer (`lib/feature/profile/data/`):**
  - Model: `ProfilePictureModel` with resilient JSON parsing for camelCase and snake_case (`mediaUrl` / `media_url`, `isActive` / `is_active`, `createdAt` / `created_at`).
  - `ProfileRemoteDataSourceImpl`:
    - `getProfilePictures()`: Invokes `GET /v1/users/me/profile-pictures` with Bearer auth, handles array and wrapped response formats.
    - `addProfilePicture(mediaUrl)`: Invokes `POST /v1/users/me/profile-pictures` with `{ "mediaUrl": mediaUrl }`.
    - `activateProfilePicture(id)`: Invokes `PATCH /v1/users/me/profile-pictures/{id}/activate`.
    - `deleteProfilePicture(id)`: Invokes `DELETE /v1/users/me/profile-pictures/{id}`.
  - `ProfileRepositoryImpl`: Maps remote data source responses to `Either<Failure, ...>`.
- **Presentation Layer (`lib/feature/profile/presentation/`):**
  - `ProfileEvent`:
    - `LoadProfilePicturesEvent`
    - `UploadProfilePictureEvent(imageFile)`
    - `ActivateProfilePictureEvent(pictureId)`
    - `DeleteProfilePictureEvent(pictureId)`
  - `ProfileState`:
    - Stores `profilePictures` list, `isUploadingPicture`, and `isManagingPicture` flags.
    - Getter `activeProfilePicture`: Returns the picture with `isActive == true`, falling back to first picture or `null`.
  - `ProfileBloc`:
    - Handles `UploadProfilePictureEvent`: Obtains signed upload URL via `GetUploadUrlUseCase(folder: "avatars")`, performs binary upload via `UploadFileUseCase`, calls `AddProfilePictureUseCase`, and if no pictures existed previously, auto-activates it.
    - Handles `ActivateProfilePictureEvent`: Calls `ActivateProfilePictureUseCase`, updates active status in state, and emits success toast.
    - Handles `DeleteProfilePictureEvent`: Calls `DeleteProfilePictureUseCase`, removes picture from state, and emits confirmation toast.
    - Synchronously initiates profile pictures fetch alongside `LoadProfileEvent`.
  - `ProfileScreen`:
    - **Header Avatar:** Shows active profile picture (`state.activeProfilePicture?.mediaUrl`) in a circular container with brand accent border and camera icon badge overlay. Falls back to user initials (`_buildInitialsAvatar`) if no image is set or if loading fails.
    - **Interactive Tap:** Tapping the avatar opens the Profile Pictures modal bottom sheet.
    - **Profile Pictures Modal (`_showProfilePicturesModal`):**
      - Grid view of all uploaded pictures with status badge (`"Actif"` in secondary green `#86AB3E`) on the active photo.
      - Tapping any inactive photo dispatches `ActivateProfilePictureEvent`.
      - Delete icon on top-right of each thumbnail confirms and dispatches `DeleteProfilePictureEvent`.
      - "Ajouter une photo" button triggers camera/gallery picker sheet (`_showImageSourcePicker`) and triggers `UploadProfilePictureEvent`.
- **DI & Tests:**
  - Registered all 4 use cases in `injection_container.dart` and injected `GetUploadUrlUseCase`, `UploadFileUseCase`, and the new profile picture use cases into `ProfileBloc`.
  - Added unit test suite in `test/feature/profile/profile_bloc_test.dart` testing `ProfilePictureModel` deserialization, active profile picture state resolution, photo loading, activation, and deletion.
  - Verified with `flutter test` (all 63 tests passing) and `flutter analyze` (0 issues).





