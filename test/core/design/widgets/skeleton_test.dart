import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<String> value, {
  SkeletonLayout layout = SkeletonLayout.list,
  bool reduceMotion = false,
}) => tester.pumpWidget(
  MaterialApp(
    theme: SpaceTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            AsyncSlivers<String>(
              value: value,
              onRetry: () {},
              skeleton: layout,
              builder: (text) => SliverToBoxAdapter(child: Text(text)),
            ),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('a first load shows a shimmering skeleton, not a spinner', (
    tester,
  ) async {
    for (final layout in SkeletonLayout.values) {
      await _pump(tester, const AsyncLoading(), layout: layout);
      expect(find.byType(Shimmer), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.bySemanticsLabel('Loading…'), findsWidgets);
    }

    await _pump(tester, const AsyncData('Loaded'));
    expect(find.text('Loaded'), findsOneWidget);
    expect(find.byType(Shimmer), findsNothing);
  });

  testWidgets('the skeleton holds still when motion is reduced', (
    tester,
  ) async {
    await _pump(tester, const AsyncLoading(), reduceMotion: true);
    final shimmer = tester.widget<Shimmer>(find.byType(Shimmer).first);
    expect(shimmer.enabled, isFalse);
    // Nothing animates, so the frame settles.
    await tester.pumpAndSettle();
  });
}
