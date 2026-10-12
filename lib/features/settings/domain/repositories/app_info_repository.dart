import '../entities/app_version.dart';

abstract interface class AppInfoRepository {
  /// What's installed on this phone.
  Future<AppVersion> getVersion();
}
