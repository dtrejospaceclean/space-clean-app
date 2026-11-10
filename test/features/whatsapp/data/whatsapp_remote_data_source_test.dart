import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/network/auth_interceptor.dart';
import 'package:sp_cln_app/core/storage/token_storage.dart';
import 'package:sp_cln_app/features/whatsapp/data/datasources/whatsapp_remote_data_source.dart';
import 'package:sp_cln_app/features/whatsapp/data/repositories/whatsapp_repository_impl.dart';
import 'package:sp_cln_app/features/whatsapp/domain/entities/ticket.dart';

typedef Reply = (int status, Object? body);

/// Answers like the bot (bare JSON, `{code, message}` errors) and our API's
/// `/auth/refresh` (the envelope).
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Reply Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _ticket = {
  'id': '6f1c0000-0000-4000-8000-000000000001',
  'status': 'ASSIGNED',
  'contact': {'id': 'a2', 'waId': '50488887777', 'name': 'Ana'},
  'assignedAgent': {'id': '9b', 'name': 'Nelson'},
  'openedAt': '2026-11-09T14:02:11.000Z',
  'closedAt': null,
  'lastMessage': {
    'id': 'c4',
    'ticketId': '6f1c0000-0000-4000-8000-000000000001',
    'direction': 'INBOUND',
    'sentBy': 'CUSTOMER',
    'agent': null,
    'type': 'text',
    'body': 'Hola, necesito ayuda',
    'status': null,
    'createdAt': '2026-11-09T14:05:00.000Z',
  },
  'replyWindowClosesAt': '2026-11-10T14:05:00.000Z',
};

Reply unauthenticated() =>
    (401, {'code': 'UNAUTHENTICATED', 'message': 'Not signed in'});

void main() {
  late TokenStorage tokens;
  late FakeAdapter adapter;
  late WhatsAppRepositoryImpl repository;
  late int expired;

  void setUpBot(Reply Function(RequestOptions options) handler) {
    adapter = FakeAdapter(handler);
    final bot = Dio(BaseOptions(baseUrl: 'http://bot.test'))
      ..httpClientAdapter = adapter;
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter;
    bot.interceptors.add(
      AuthInterceptor(
        dio: bot,
        refreshDio: refreshDio,
        tokenStorage: tokens,
        endsSessionOnRefusedReplay: false,
      ),
    );
    repository = WhatsAppRepositoryImpl(WhatsAppRemoteDataSource(bot));
  }

  String? bearer(RequestOptions o) => o.headers['Authorization'] as String?;

  Reply refreshed() => (
    200,
    {
      'success': true,
      'message': 'ok',
      'data': {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
      'errors': null,
      'statusCode': 200,
    },
  );

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tokens = TokenStorage(const FlutterSecureStorage());
    await tokens.save(
      const AuthTokens(accessToken: 'old-access', refreshToken: 'old-refresh'),
    );
    expired = 0;
    tokens.sessionExpired.listen((_) => expired++);
  });

  test('sends our token and reads a bare list of tickets', () async {
    setUpBot((_) => (200, [_ticket]));

    final list = await repository.getTickets(TicketView.mine);

    final sent = adapter.requests.single;
    expect(sent.path, '/api/tickets');
    expect(sent.queryParameters, {'view': 'mine'});
    expect(bearer(sent), 'Bearer old-access');
    final t = list.single;
    expect(t.status, TicketStatus.assigned);
    expect(t.contact.displayName, 'Ana');
    expect(t.contact.phone, '+50488887777');
    expect(t.assignedAgent?.name, 'Nelson');
    expect(t.lastMessage?.sender, MessageSender.customer);
    expect(t.lastMessage?.body, 'Hola, necesito ayuda');
    expect(t.replyWindowClosesAt?.toUtc(), DateTime.utc(2026, 11, 10, 14, 5));
  });

  test('refreshes our token when the bot says UNAUTHENTICATED', () async {
    setUpBot(
      (o) => switch (o.path) {
        '/auth/refresh' => refreshed(),
        _ when bearer(o) == 'Bearer new-access' => (
          200,
          {'id': '9b', 'name': 'Nelson', 'email': 'n@x.com'},
        ),
        _ => unauthenticated(),
      },
    );

    final me = await repository.getMe();

    expect(me.id, '9b');
    expect(adapter.requests.map((r) => r.path), [
      '/api/auth/me',
      '/auth/refresh',
      '/api/auth/me',
    ]);
    expect((await tokens.read())?.accessToken, 'new-access');
  });

  test('a refusal even with fresh tokens keeps the app signed in', () async {
    setUpBot(
      (o) => o.path == '/auth/refresh' ? refreshed() : unauthenticated(),
    );

    await expectLater(
      repository.getTickets(TicketView.open),
      throwsA(
        isA<UnauthorizedFailure>().having(
          (f) => f.messageKey,
          'key',
          'whatsapp.unauthenticated',
        ),
      ),
    );
    expect(expired, 0);
  });

  test("turns the bot's codes into whatsapp.* keys", () async {
    setUpBot(
      (_) => (
        409,
        {'code': 'TICKET_ASSIGNED_TO_ANOTHER_AGENT', 'message': 'Take it'},
      ),
    );

    await expectLater(
      repository.reply(_ticket['id']! as String, 'Hola'),
      throwsA(
        isA<ServerFailure>()
            .having(
              (f) => f.messageKey,
              'key',
              'whatsapp.ticket_assigned_to_another_agent',
            )
            .having((f) => f.statusCode, 'status', 409),
      ),
    );
    expect(adapter.requests.single.data, {'body': 'Hola'});
  });

  test('reads a ticket with its messages, oldest first', () async {
    setUpBot(
      (_) => (
        200,
        {
          ..._ticket,
          'messages': [
            _ticket['lastMessage'],
            {
              'id': 'd5',
              'ticketId': _ticket['id'],
              'direction': 'OUTBOUND',
              'sentBy': 'AGENT',
              'agent': {'id': '9b', 'name': 'Nelson'},
              'type': 'text',
              'body': 'Claro',
              'status': 'read',
              'createdAt': '2026-11-09T14:06:00.000Z',
            },
          ],
        },
      ),
    );

    final d = await repository.getTicket(_ticket['id']! as String);

    expect(d.messages.map((m) => m.body), ['Hola, necesito ayuda', 'Claro']);
    expect(d.messages.last.agent?.id, '9b');
    expect(d.messages.last.delivery, DeliveryStatus.read);
    expect(d.messages.first.isFromCustomer, isTrue);
  });

  test('offline is a network failure', () {
    final e = botException(
      DioException(requestOptions: RequestOptions(path: '/api/tickets')),
    );
    expect(e.toFailure(), isA<NetworkFailure>());
    expect(
      botException(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(requestOptions: RequestOptions(), statusCode: 502),
        ),
      ).key,
      'whatsapp.internal_error',
    );
  });
}
