import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/ticket.dart';
import '../models/ticket_model.dart';

/// Talks to the WhatsApp bot's `/api`. It answers bare JSON, not our
/// envelope, and fails with `{code, message}`; each code becomes the key
/// `whatsapp.<code>` (`TICKET_CLOSED` → `whatsapp.ticket_closed`). Throws
/// `ApiException`.
class WhatsAppRemoteDataSource {
  const WhatsAppRemoteDataSource(this._dio);

  final Dio _dio;

  static const _tickets = '/api/tickets';

  Future<T> _send<T>(
    Future<Response<Object?>> Function() request,
    T Function(Object? data) read,
  ) async {
    try {
      return read((await request()).data);
    } on DioException catch (e) {
      throw botException(e);
    }
  }

  static Map<String, dynamic> _map(Object? data) =>
      (data! as Map).cast<String, dynamic>();

  static Ticket _ticket(Object? data) => TicketModel.fromJson(_map(data));

  Future<BotAgent> getMe() => _send(
    () => _dio.get<Object?>('/api/auth/me'),
    (data) => TicketModel.agent(_map(data)),
  );

  Future<List<Ticket>> getTickets(TicketView view) => _send(
    () => _dio.get<Object?>(_tickets, queryParameters: {'view': view.wire}),
    (data) => [for (final t in data! as List) _ticket(t)],
  );

  Future<TicketDetail> getTicket(String ticketId) => _send(
    () => _dio.get<Object?>('$_tickets/$ticketId'),
    (data) => TicketModel.detail(_map(data)),
  );

  /// Takes no body.
  Future<Ticket> takeTicket(String ticketId) =>
      _send(() => _dio.post<Object?>('$_tickets/$ticketId/take'), _ticket);

  /// Takes no body.
  Future<Ticket> closeTicket(String ticketId) =>
      _send(() => _dio.post<Object?>('$_tickets/$ticketId/close'), _ticket);

  Future<BotMessage> reply(String ticketId, String body) => _send(
    () => _dio.post<Object?>(
      '$_tickets/$ticketId/messages',
      data: {'body': body},
    ),
    (data) => TicketModel.message(_map(data)),
  );
}

/// The bot's error as an [ApiException] keyed `whatsapp.<code>`.
ApiException botException(DioException error) {
  final response = error.response;
  if (response == null) {
    return const ApiException(key: NetworkFailure.key, statusCode: 0);
  }
  final status = response.statusCode ?? 0;
  final code = switch (response.data) {
    {'code': final String code} => code.toLowerCase(),
    _ when status >= 500 => 'internal_error',
    _ => 'unknown',
  };
  return ApiException(key: 'whatsapp.$code', statusCode: status);
}
