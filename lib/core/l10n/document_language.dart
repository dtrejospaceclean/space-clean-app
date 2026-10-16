import 'package:flutter/widgets.dart';

/// The language the server writes documents and emails in: the app's, which
/// is English or Spanish.
String documentLanguage(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'es';
