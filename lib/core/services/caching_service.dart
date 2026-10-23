import 'package:shared_preferences/shared_preferences.dart';

const String latitudeKey = 'business_latitude';
const String longitudeKey = 'business_longitude';
const String serviceIdKey = 'service_id';
const String addressIdKey = 'address_id';
const String addressStreetKey = 'address_street';
const String addressTitleKey = 'address_title';
const String businessTitleKey = 'business_title';
const String businessDescriptionKey = 'business_description';
const String businessCategoryIdKey = 'business_category_id';

/// Contract for general local key-value caching (e.g. SharedPreferences).
abstract class CachingService {
  Future<void> saveDouble(String key, double value);
  double? getDouble(String key);
  Future<void> saveString(String key, String value);
  String? getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Implementation of [CachingService] using [SharedPreferences].
class CachingServiceImpl implements CachingService {
  final SharedPreferences sharedPreferences;

  const CachingServiceImpl({required this.sharedPreferences});

  @override
  Future<void> saveDouble(String key, double value) async {
    await sharedPreferences.setDouble(key, value);
  }

  @override
  double? getDouble(String key) {
    return sharedPreferences.getDouble(key);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await sharedPreferences.setString(key, value);
  }

  @override
  String? getString(String key) {
    return sharedPreferences.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await sharedPreferences.remove(key);
  }

  @override
  Future<void> clear() async {
    await sharedPreferences.clear();
  }
}
