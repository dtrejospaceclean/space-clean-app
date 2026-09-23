enum AppLanguage {
  en,
  es;

  static AppLanguage? tryParse(String? code) => switch (code) {
    'en' => en,
    'es' => es,
    _ => null,
  };
}
