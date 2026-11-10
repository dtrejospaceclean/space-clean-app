import '../../../../core/network/api_exception.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/whatsapp_repository.dart';
import '../datasources/whatsapp_remote_data_source.dart';

class WhatsAppRepositoryImpl implements WhatsAppRepository {
  const WhatsAppRepositoryImpl(this._remote);

  final WhatsAppRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<BotAgent> getMe() => _guard(_remote.getMe);

  @override
  Future<List<Ticket>> getTickets(TicketView view) =>
      _guard(() => _remote.getTickets(view));

  @override
  Future<TicketDetail> getTicket(String ticketId) =>
      _guard(() => _remote.getTicket(ticketId));

  @override
  Future<Ticket> takeTicket(String ticketId) =>
      _guard(() => _remote.takeTicket(ticketId));

  @override
  Future<Ticket> closeTicket(String ticketId) =>
      _guard(() => _remote.closeTicket(ticketId));

  @override
  Future<BotMessage> reply(String ticketId, String body) =>
      _guard(() => _remote.reply(ticketId, body));
}
