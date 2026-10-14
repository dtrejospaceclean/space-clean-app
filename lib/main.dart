import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/refresh/live_data.dart';
import 'core/storage/preferences.dart';
import 'features/notifications/di/notifications_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final pushEnabled = await _startFirebase();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        pushEnabledProvider.overrideWithValue(pushEnabled),
      ],
      // Failed loads show an error with Retry (and pull to refresh) instead
      // of retrying silently in the background.
      retry: (_, _) => null,
      observers: const [LiveDataObserver()],
      child: const App(),
    ),
  );
}

/// Push notifications need Firebase; without it the app runs without them.
Future<bool> _startFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (error) {
    debugPrint('Firebase failed to start, so no pushes: $error');
    return false;
  }
}
