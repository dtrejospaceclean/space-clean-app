import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/profile/domain/entities/profile_photo.dart';
import 'package:sp_cln_app/features/profile/presentation/photo_picker.dart';

import '../../../helpers/test_app.dart';

Future<FakeProfileRepository> openMe(
  WidgetTester tester,
  FakeAuthRepository auth, {
  PhotoPicker? photoPicker,
}) async {
  final profile = FakeProfileRepository(auth);
  await pumpApp(tester, auth: auth, profile: profile, photoPicker: photoPicker);
  await tester.tap(find.byTooltip('Me'));
  await tester.pumpAndSettle();
  return profile;
}

void main() {
  testWidgets('anyone edits their own profile from Me', (tester) async {
    final auth = FakeAuthRepository(sessionUser: ana);
    final profile = await openMe(tester, auth);

    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    // Email isn't theirs to change; the form says who can.
    expect(find.text('Email'), findsNothing);
    expect(find.textContaining('ana@example.com'), findsOneWidget);

    await tester.enterText(field('Full name'), 'Ana M. Pérez');
    // A number without its area code is refused before saving.
    await tester.enterText(field('Phone').first, '555-0100');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a 10-digit phone number.'), findsOneWidget);
    expect(profile.writes, isEmpty);

    await tester.enterText(field('Phone').first, '713-555-0100');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(profile.writes, ['profile']);
    expect(auth.sessionUser!.phoneNumber, '(713) 555-0100');
    // Back on Me, with the new name.
    expect(find.byTooltip('Edit profile'), findsOneWidget);
    expect(find.text('Ana M. Pérez'), findsOneWidget);
  });

  testWidgets('a blank name is refused before saving', (tester) async {
    final auth = FakeAuthRepository(sessionUser: ana);
    final profile = await openMe(tester, auth);
    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Full name'), '  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(profile.writes, isEmpty);
    expect(find.text('This field is required.'), findsOneWidget);
  });

  group('profile photo', () {
    final picked = ProfilePhoto(bytes: Uint8List(800000), name: 'me.jpg');

    Future<void> openPhotoMenu(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Change profile photo'));
      await tester.pumpAndSettle();
    }

    testWidgets('sets a photo from the library, then removes it', (
      tester,
    ) async {
      final auth = FakeAuthRepository(sessionUser: ana);
      final picker = FakePhotoPicker(picked);
      final profile = await openMe(tester, auth, photoPicker: picker);

      await openPhotoMenu(tester);
      // Nothing to remove yet.
      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Remove photo'), findsNothing);
      await tester.tap(find.text('Choose from library'));
      await tester.pumpAndSettle();

      expect(picker.sources, [PhotoSource.library]);
      expect(profile.writes, ['photo me.jpg']);
      expect(auth.sessionUser!.photoUrl, isNotNull);

      await openPhotoMenu(tester);
      await tester.tap(find.text('Remove photo'));
      await tester.pumpAndSettle();

      expect(profile.writes.last, 'remove photo');
      expect(auth.sessionUser!.photoUrl, isNull);
    });

    testWidgets('backing out of the camera changes nothing', (tester) async {
      final auth = FakeAuthRepository(sessionUser: ana);
      final picker = FakePhotoPicker();
      final profile = await openMe(tester, auth, photoPicker: picker);

      await openPhotoMenu(tester);
      await tester.tap(find.text('Take photo'));
      await tester.pumpAndSettle();

      expect(picker.sources, [PhotoSource.camera]);
      expect(profile.writes, isEmpty);
    });

    testWidgets('a photo over 5 MB is refused before uploading', (
      tester,
    ) async {
      final auth = FakeAuthRepository(sessionUser: ana);
      final profile = await openMe(
        tester,
        auth,
        photoPicker: FakePhotoPicker(
          ProfilePhoto(
            bytes: Uint8List(ProfilePhoto.maxBytes + 1),
            name: 'huge.png',
          ),
        ),
      );

      await openPhotoMenu(tester);
      await tester.tap(find.text('Choose from library'));
      await tester.pumpAndSettle();

      expect(profile.writes, isEmpty);
      expect(
        find.text('That photo is over 5 MB. Choose a smaller one.'),
        findsOneWidget,
      );
    });

    testWidgets('says how to allow access when the camera is denied', (
      tester,
    ) async {
      final auth = FakeAuthRepository(sessionUser: ana);
      final picker = FakePhotoPicker()..error = const PhotoAccessDenied();
      await openMe(tester, auth, photoPicker: picker);

      await openPhotoMenu(tester);
      await tester.tap(find.text('Take photo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Allow access in Settings'), findsOneWidget);
    });
  });

  group('change password', () {
    Future<FakeProfileRepository> openForm(WidgetTester tester) async {
      final profile = await openMe(
        tester,
        FakeAuthRepository(sessionUser: ana),
      );
      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      return profile;
    }

    testWidgets('a wrong current password shows on its field', (tester) async {
      final profile = await openForm(tester);

      await tester.enterText(field('Current password'), 'not it');
      await tester.enterText(field('New password'), 'a brand new secret');
      await tester.enterText(
        field('Repeat new password'),
        'a brand new secret',
      );
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();

      expect(profile.writes, isEmpty);
      expect(find.text('Your current password is incorrect.'), findsOneWidget);
    });

    testWidgets('checks length and match before calling the server', (
      tester,
    ) async {
      final profile = await openForm(tester);

      await tester.enterText(field('Current password'), profile.password);
      await tester.enterText(field('New password'), 'short');
      await tester.enterText(field('Repeat new password'), 'other');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();

      expect(profile.writes, isEmpty);
      expect(find.text("The passwords don't match."), findsOneWidget);
    });

    testWidgets('confirms the change and returns to Me', (tester) async {
      final profile = await openForm(tester);

      await tester.enterText(field('Current password'), profile.password);
      await tester.enterText(field('New password'), 'a brand new secret');
      await tester.enterText(
        field('Repeat new password'),
        'a brand new secret',
      );
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();

      expect(profile.writes, ['password']);
      expect(find.text('Password changed'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Still signed in, back on Me.
      expect(find.byTooltip('Edit profile'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
    });
  });
}
