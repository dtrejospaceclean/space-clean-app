import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/team/domain/entities/member.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

/// A supervisor who can't assign jobs here.
const _marco = Member(
  userId: 'm1',
  clientId: 'c1',
  name: 'Marco Díaz',
  email: 'marco@example.com',
  baseRole: 'supervisor',
  permissions: {'info.view', 'jobs.view', 'jobs.edit', 'team.view'},
  overrides: {'jobs.assign': false},
);

/// Opens Torre Norte → Team as [user] (a supervisor member unless owner).
Future<FakeTeamRepository> openTeam(WidgetTester tester, User user) async {
  final repo = FakeTeamRepository([_marco]);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    clients: FakeClientsRepository([_tower]),
    team: repo,
    access: FakeAccessRepository({
      'c1': const AccountAccess(
        clientId: 'c1',
        baseRole: 'supervisor',
        permissions: {Permissions.infoView, Permissions.teamView},
      ),
    }),
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Torre Norte'));
  await tester.pumpAndSettle();
  await revealBelow(tester, find.text('Team'));
  await tester.tap(find.text('Team'));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> openMarco(WidgetTester tester) async {
  await tester.tap(find.text('Marco Díaz'));
  await tester.pumpAndSettle();
}

/// The tappable box of the picker labeled [label].
Finder picker(String label) => find.descendant(
  of: find.widgetWithText(PickerField, label),
  matching: find.byType(InkWell),
);

/// The switch row for [action] under the area [module] on the access list.
Finder toggle(String module, String action) => find.descendant(
  of: find.ancestor(of: find.text(module), matching: find.byType(Column)).first,
  matching: find.text(action),
);

void main() {
  testWidgets('a supervisor sees the team but can\'t change it', (
    tester,
  ) async {
    final team = await openTeam(tester, ana);

    expect(find.text('Supervisor · Custom access'), findsOneWidget);
    expect(find.byTooltip('Create'), findsNothing);

    await openMarco(tester);
    expect(find.text('marco@example.com'), findsOneWidget);
    expect(find.text('Custom access'), findsOneWidget);
    expect(find.byTooltip('Edit access'), findsNothing);
    // Read-only access shows marks, not switches that look pressable.
    expect(find.byType(SwitchRow), findsWidgets);
    expect(find.byType(SpaceSwitch), findsNothing);
    await revealBelow(tester, find.text('Only owners can change the team.'));
    expect(find.text('Remove from team'), findsNothing);
    expect(team.writes, isEmpty);
  });

  testWidgets('an owner adds someone with the role that fits them', (
    tester,
  ) async {
    final team = await openTeam(tester, owner);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Add to team'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsNWidgets(2));
    expect(team.writes, isEmpty);

    await tester.tap(picker('Person'));
    await tester.pumpAndSettle();
    // Only active users who aren't members yet (Luis is inactive).
    expect(find.text('Luis Gómez'), findsNothing);
    await tester.tap(find.text('Ana Pérez'));
    await tester.pumpAndSettle();
    // Ana is a supervisor, so that's where she starts.
    expect(find.text('Supervisor'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(team.writes, ['member:u1:supervisor']);
    // On her new member screen.
    expect(find.text('Team member'), findsOneWidget);
    expect(find.text('Remove from team'), findsOneWidget);
  });

  testWidgets('an owner gives a member back a permission', (tester) async {
    final team = await openTeam(tester, owner);
    await openMarco(tester);

    await tester.tap(find.byTooltip('Edit access'));
    await tester.pumpAndSettle();
    await revealBelow(tester, toggle('Jobs', 'Assign'));
    await tester.tap(toggle('Jobs', 'Assign'));
    await tester.pumpAndSettle();
    // Back to the supervisor defaults.
    expect(find.text('Reset to the role\'s defaults'), findsNothing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(team.writes, ['overrides:m1:{}']);
    expect(find.text('Custom access'), findsNothing);
  });

  testWidgets('turning off View turns off the rest of the area', (
    tester,
  ) async {
    final team = await openTeam(tester, owner);
    await openMarco(tester);
    await tester.tap(find.byTooltip('Edit access'));
    await tester.pumpAndSettle();

    await revealBelow(tester, toggle('Jobs', 'View'));
    await tester.tap(toggle('Jobs', 'View'));
    await tester.pumpAndSettle();
    // The rest of the area's switches turned off with it.
    for (final action in ['View', 'Edit', 'Assign']) {
      expect(
        tester.getSemantics(
          find.ancestor(
            of: toggle('Jobs', action),
            matching: find.byType(SwitchRow),
          ),
        ),
        isSemantics(hasToggledState: true, isToggled: false),
      );
    }
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(team.writes, [
      'overrides:m1:{jobs.view: false, jobs.edit: false, jobs.assign: false}',
    ]);
  });

  testWidgets('a new role starts from its defaults', (tester) async {
    final team = await openTeam(tester, owner);
    await openMarco(tester);
    await tester.tap(find.byTooltip('Edit access'));
    await tester.pumpAndSettle();

    await tester.tap(picker('Role on this account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crew').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The role first, then the old override cleared.
    expect(team.writes, ['member:m1:crew', 'overrides:m1:{}']);
    expect(find.text('Crew'), findsOneWidget);
  });

  testWidgets('an owner removes a member', (tester) async {
    final team = await openTeam(tester, owner);
    await openMarco(tester);

    await revealBelow(tester, find.text('Remove from team'));
    await tester.tap(find.text('Remove from team'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Marco Díaz?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(team.writes, ['remove:m1']);
    expect(find.text('No one on this team yet'), findsOneWidget);
  });
}
