import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/entities/app_version.dart';
import '../../domain/repositories/app_info_repository.dart';

/// Reads the version from the installed app: `versionName`/`versionCode` on
/// Android, `CFBundleShortVersionString`/`CFBundleVersion` on iOS.
class AppInfoRepositoryImpl implements AppInfoRepository {
  const AppInfoRepositoryImpl();

  @override
  Future<AppVersion> getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersion(version: info.version, build: info.buildNumber);
  }
}
