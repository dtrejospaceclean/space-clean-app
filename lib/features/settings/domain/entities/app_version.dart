/// The installed app's version, as the store and the phone's settings show
/// it: [version] ("0.0.3") is the release, [build] ("3") counts uploads.
/// Both come from `version:` in pubspec.yaml (`0.0.3+3`), which Android and
/// iOS each take as their own.
class AppVersion {
  const AppVersion({required this.version, required this.build});

  final String version;
  final String build;
}
