import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/core/domain/picked_photo.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/media/photo_picker.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/complaints/domain/entities/complaint.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';
import 'package:sp_cln_app/features/team/domain/entities/member.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

/// High, open and unassigned.
final _paper = Complaint(
  id: 'q-paper',
  clientId: 'c1',
  title: 'Restrooms out of paper',
  description: 'No paper on floor 3 since this morning.',
  priority: Priority.high,
  status: ComplaintStatus.open,
  reportedDate: DateTime(2026, 9, 22, 9),
  locationId: 'l1',
  locationName: 'Floor 3',
  area: 'Restrooms',
  jobId: 'j-night',
  jobTitle: 'Night clean',
  jobStart: DateTime(2026, 9, 21, 19),
  reportedByName: 'Carlos Medina',
);

/// Low and newer, so it comes after the high one.
final _bins = Complaint(
  id: 'q-bins',
  clientId: 'c1',
  title: 'Bins not emptied',
  description: 'Lobby bins were full on Monday.',
  priority: Priority.low,
  status: ComplaintStatus.open,
  reportedDate: DateTime(2026, 9, 23, 7),
);

/// Resolved two hours after it was reported.
final _carpet = Complaint(
  id: 'q-carpet',
  clientId: 'c1',
  title: 'Carpet stains',
  description: 'Coffee stains by the elevators.',
  priority: Priority.medium,
  status: ComplaintStatus.resolved,
  reportedDate: DateTime(2026, 9, 10, 9),
  assignedToId: 'u-ana',
  assignedToName: 'Ana Pérez',
  resolvedByName: 'Marco Díaz',
  resolutionTime: DateTime(2026, 9, 10, 13, 30),
  resolutionHours: 4.5,
  resolutionNotes: 'Shampooed the carpet.',
);

const _viewer = {Permissions.complaintsView};
const _editor = {
  Permissions.complaintsView,
  Permissions.complaintsEdit,
  Permissions.complaintsAssign,
  Permissions.infoView,
  Permissions.teamView,
  Permissions.jobsView,
};

/// Opens Torre Norte → Complaints as a member with [permissions].
Future<FakeComplaintsRepository> openComplaints(
  WidgetTester tester, {
  Set<String> permissions = _viewer,
  List<Complaint>? complaints,
  FakePhotoPicker? photoPicker,
}) async {
  final repo = FakeComplaintsRepository(complaints ?? [_bins, _paper, _carpet]);
  await pumpApp(
    tester,
    photoPicker: photoPicker,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: FakeClientsRepository([_tower]),
    complaints: repo,
    jobs: FakeJobsRepository({
      'c1': [job('j-night', 'c1', title: 'Night clean', day: 21, hour: 19)],
    }),
    locations: FakeLocationsRepository(const [
      Location(
        id: 'l1',
        clientId: 'c1',
        name: 'Floor 3',
        address: '1980 Post Oak Blvd',
        city: 'Houston',
        state: 'TX',
        zipCode: '77056',
      ),
    ]),
    team: FakeTeamRepository(const [
      Member(
        userId: 'u-ana',
        clientId: 'c1',
        name: 'Ana Pérez',
        email: 'ana@spaceclean.com',
        baseRole: 'supervisor',
      ),
      Member(
        userId: 'u-client',
        clientId: 'c1',
        name: 'Carlos Medina',
        email: 'carlos@torrenorte.com',
        baseRole: 'client',
      ),
    ]),
    access: FakeAccessRepository({
      'c1': AccountAccess(
        clientId: 'c1',
        baseRole: 'supervisor',
        permissions: permissions,
      ),
    }),
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Torre Norte'));
  await tester.pumpAndSettle();
  await revealBelow(tester, find.text('Complaints'));
  await tester.tap(find.text('Complaints'));
  await tester.pumpAndSettle();
  return repo;
}

/// The tappable box of the form's picker labeled [label].
Finder _picker(String label) => find.descendant(
  of: find.widgetWithText(PickerField, label),
  matching: find.byType(InkWell),
);

/// The vertical order of [texts] on screen.
List<String> _topToBottom(WidgetTester tester, List<String> texts) =>
    [...texts]..sort(
      (a, b) => tester
          .getTopLeft(find.text(a))
          .dy
          .compareTo(tester.getTopLeft(find.text(b)).dy),
    );

void main() {
  testWidgets('a viewer sees open complaints by urgency, then the resolved', (
    tester,
  ) async {
    final complaints = await openComplaints(tester);

    expect(find.text('Open (2)'), findsOneWidget);
    expect(find.byTooltip('Create'), findsNothing);
    // High before low, though the low one is newer.
    expect(
      _topToBottom(tester, ['Bins not emptied', 'Restrooms out of paper']),
      ['Restrooms out of paper', 'Bins not emptied'],
    );
    expect(find.text('Floor 3 · Restrooms · Sep 22, 2026'), findsOneWidget);
    expect(find.text('Carpet stains'), findsNothing);

    await tester.tap(find.text('Resolved'));
    await tester.pumpAndSettle();
    expect(find.text('Carpet stains'), findsOneWidget);
    expect(find.text('Restrooms out of paper'), findsNothing);

    // Read-only: no Edit, Resolve or Reopen.
    await tester.tap(find.text('Carpet stains'));
    await tester.pumpAndSettle();
    expect(find.text('Coffee stains by the elevators.'), findsOneWidget);
    await revealBelow(tester, find.text('Shampooed the carpet.'));
    expect(find.text('Marco Díaz'), findsOneWidget);
    expect(find.text('4.5 h'), findsOneWidget);
    expect(find.byTooltip('Edit complaint'), findsNothing);
    expect(find.text('Reopen'), findsNothing);
    expect(complaints.writes, isEmpty);
  });

  testWidgets('an editor reports a complaint from "+"', (tester) async {
    final complaints = await openComplaints(tester, permissions: _editor);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New complaint'), findsOneWidget);

    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    // Title and description are required before calling the API.
    expect(find.text('This field is required.'), findsNWidgets(2));
    expect(complaints.writes, isEmpty);

    await tester.enterText(field('Title'), 'Windows streaked');
    await tester.enterText(field('Description'), 'Lobby glass, outside.');
    await tester.tap(find.text('High'));
    await revealBelow(tester, _picker('Location'));
    await tester.tap(_picker('Location'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Floor 3').last);
    await tester.pumpAndSettle();
    // Only the account's own staff can take it, not the client's people.
    await revealBelow(tester, _picker('Assigned to'));
    await tester.tap(_picker('Assigned to'));
    await tester.pumpAndSettle();
    expect(find.text('Carlos Medina'), findsNothing);
    await tester.tap(find.text('Ana Pérez').last);
    await tester.pumpAndSettle();
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(complaints.writes, ['create:Windows streaked']);
    final draft = complaints.drafts.single;
    expect(draft.priority, Priority.high);
    expect(draft.locationId, 'l1');
    expect(draft.assignedToId, 'u-ana');
    // Its own page: assigned, so already in progress.
    expect(find.text('Complaint'), findsOneWidget);
    expect(find.text('Windows streaked'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
  });

  testWidgets('a new complaint uploads its photos once it is saved', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final picker = FakePhotoPicker();
    final complaints = await openComplaints(
      tester,
      permissions: _editor,
      photoPicker: picker,
    );
    complaints.photoFailures['/tmp/c.jpg'] = const ServerFailure(
      'complaints.photo_invalid_type',
      statusCode: 400,
    );
    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Title'), 'Windows streaked');
    await tester.enterText(field('Description'), 'Lobby glass, outside.');

    Future<void> add(String path, {int size = 900000}) async {
      picker.next = PickedPhoto(path: path, sizeInBytes: size);
      await revealBelow(tester, find.byType(PhotoStrip));
      await tester.tap(find.bySemanticsLabel('Add photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from library'));
      await tester.pumpAndSettle();
    }

    // Too large is refused on the phone, before anything is sent.
    await add('/tmp/huge.jpg', size: PickedPhoto.maxBytes + 1);
    expect(find.textContaining('over 5 MB'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await add('/tmp/a.jpg');
    await add('/tmp/b.jpg');
    await add('/tmp/x.jpg');
    // A third is the limit: the add tile goes.
    expect(find.bySemanticsLabel('Add photo'), findsNothing);
    await revealBelow(tester, find.byType(PhotoStrip));
    await tester.tap(find.bySemanticsLabel('Remove photo, Photo 3 of 3'));
    await tester.pumpAndSettle();
    await add('/tmp/c.jpg');
    expect(complaints.writes, isEmpty);

    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(complaints.writes, [
      'create:Windows streaked',
      'photo:q4:/tmp/a.jpg',
      'photo:q4:/tmp/b.jpg',
    ]);
    // The one that failed is told, and the complaint still opens.
    expect(
      find.textContaining("1 photo couldn't be added: Use a JPEG"),
      findsOneWidget,
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Windows streaked'), findsOneWidget);
    await revealBelow(tester, find.byType(PhotoStrip));
    expect(find.bySemanticsLabel('Photo 2 of 2'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('photos are added and removed on the page', (tester) async {
    final semantics = tester.ensureSemantics();
    final picker = FakePhotoPicker(
      const PickedPhoto(path: '/tmp/stain.jpg', sizeInBytes: 900000),
    );
    final complaints = await openComplaints(
      tester,
      permissions: _editor,
      photoPicker: picker,
    );
    await tester.tap(find.text('Restrooms out of paper'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.byType(PhotoStrip));
    expect(find.text('PHOTOS'), findsOneWidget);
    expect(find.text('Add up to 3 photos of what happened.'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    expect(picker.sources, [PhotoSource.camera]);
    expect(complaints.writes, ['photo:q-paper:/tmp/stain.jpg']);
    expect(find.bySemanticsLabel('Photo 1 of 1'), findsOneWidget);

    // Opened full screen, it can be removed after a confirmation.
    await tester.tap(find.bySemanticsLabel('Photo 1 of 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove photo'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this photo?'), findsOneWidget);
    await tester.tap(find.text('Remove photo').last);
    await tester.pumpAndSettle();
    expect(complaints.writes.last, 'unphoto:q-paper:ph1');
    expect(find.bySemanticsLabel('Photo 1 of 1'), findsNothing);
    expect(find.text('Restrooms out of paper'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a viewer sees the photos but cannot change them', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final withPhoto = Complaint(
      id: 'q-photo',
      clientId: 'c1',
      title: 'Stained carpet',
      description: 'By the elevators.',
      priority: Priority.medium,
      status: ComplaintStatus.open,
      reportedDate: DateTime(2026, 9, 22, 9),
      photos: [
        ComplaintPhoto(
          id: 'ph1',
          url: 'https://cdn.test/a.webp',
          createdAt: DateTime(2026, 9, 22, 9),
        ),
      ],
    );
    await openComplaints(tester, complaints: [withPhoto, _bins]);
    await tester.tap(find.text('Stained carpet'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.byType(PhotoStrip));
    expect(find.bySemanticsLabel('Add photo'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Photo 1 of 1'));
    await tester.pumpAndSettle();
    expect(find.text('Photo'), findsOneWidget);
    expect(find.byTooltip('Remove photo'), findsNothing);
    semantics.dispose();
  });

  testWidgets('an editor assigns, resolves and reopens a complaint', (
    tester,
  ) async {
    final complaints = await openComplaints(tester, permissions: _editor);
    await tester.tap(find.text('Restrooms out of paper'));
    await tester.pumpAndSettle();
    expect(find.text('Reported Sep 22, 2026 by Carlos Medina'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);

    await revealBelow(tester, find.text('Assigned to'));
    await tester.tap(find.text('Assigned to'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Pérez').last);
    await tester.pumpAndSettle();
    expect(complaints.writes, ['assign:q-paper:u-ana']);
    expect(find.text('In progress'), findsOneWidget);

    // Resolving needs a note on what was done.
    await revealBelow(tester, button('Resolve'));
    await tester.tap(button('Resolve'));
    await tester.pumpAndSettle();
    expect(find.text('Resolve complaint'), findsOneWidget);
    await tester.tap(button('Resolve'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsOneWidget);
    await tester.enterText(field('What was done'), ' Restocked every floor. ');
    await tester.tap(button('Resolve'));
    await tester.pumpAndSettle();

    expect(complaints.writes.last, 'resolve:q-paper');
    expect(
      complaints.complaints
          .firstWhere((c) => c.id == 'q-paper')
          .resolutionNotes,
      'Restocked every floor.',
    );
    expect(find.text('Resolved'), findsOneWidget);
    // Read-only now: no Edit, no Resolve; Reopen instead.
    expect(find.byTooltip('Edit complaint'), findsNothing);
    await revealBelow(tester, find.text('Reopen'));
    expect(button('Resolve'), findsNothing);
    expect(find.text('Restocked every floor.'), findsOneWidget);

    await tester.tap(find.text('Reopen'));
    await tester.pumpAndSettle();
    expect(find.text('Reopen this complaint?'), findsOneWidget);
    await tester.tap(find.text('Reopen').last);
    await tester.pumpAndSettle();
    expect(complaints.writes.last, 'reopen:q-paper');
    // Assigned, so it goes back to in progress.
    await tester.scrollUntilVisible(
      find.text('In progress'),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('In progress'), findsOneWidget);
  });

  testWidgets('an edit clears the area and keeps the assignee out', (
    tester,
  ) async {
    final complaints = await openComplaints(tester, permissions: _editor);
    await tester.tap(find.text('Restrooms out of paper'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit complaint'));
    await tester.pumpAndSettle();
    expect(find.text('Assigned to'), findsNothing);
    await revealBelow(tester, field('Area'));
    await tester.enterText(field('Area'), '');
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(complaints.writes, ['update:q-paper']);
    final draft = complaints.drafts.single;
    expect(draft.area, '');
    expect(draft.assignedToId, isNull);
    expect(draft.locationId, 'l1');
    expect(find.text('Restrooms'), findsNothing);
  });

  testWidgets('a job lists its complaints, and one is reported from it', (
    tester,
  ) async {
    final complaints = await openComplaints(tester, permissions: _editor);
    await tester.tap(find.text('Restrooms out of paper'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Night clean · Sep 21, 2026'));
    await tester.tap(find.text('Night clean · Sep 21, 2026'));
    await tester.pumpAndSettle();

    // The job's page, with the complaint about it at the end.
    await revealBelow(tester, find.text('Restrooms out of paper'));
    expect(find.text('Complaints'), findsOneWidget);
    expect(find.text('Bins not emptied'), findsNothing);

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(find.text('New complaint'), findsOneWidget);
    // Linked to the job, and where it was.
    await revealBelow(tester, find.text('Night clean · Sep 21, 2026'));
    expect(find.text('Floor 3'), findsOneWidget);
    await tester.enterText(field('Title'), 'Floor not mopped');
    await tester.enterText(field('Description'), 'Sticky by the kitchen.');
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(complaints.writes, ['create:Floor not mopped']);
    final draft = complaints.drafts.single;
    expect(draft.jobId, 'j-night');
    expect(draft.locationId, 'l1');
    // Back on the job, which lists both now.
    await revealBelow(tester, find.text('Floor not mopped'));
    expect(find.text('Restrooms out of paper'), findsOneWidget);
    expect(find.text('New complaint'), findsNothing);
  });

  testWidgets('the search matches title, place and people', (tester) async {
    await openComplaints(tester);
    Future<void> search(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    await search('carlos');
    expect(find.text('Restrooms out of paper'), findsOneWidget);
    expect(find.text('Bins not emptied'), findsNothing);

    await search('bins');
    expect(find.text('Bins not emptied'), findsOneWidget);
    expect(find.text('Restrooms out of paper'), findsNothing);

    // Resolved, so not among the open ones.
    await search('carpet');
    expect(find.text('Nothing matches'), findsOneWidget);
  });
}
