import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/ticket.dart';
import '../repositories/whatsapp_repository.dart';

/// Who may open the bot's tickets: global owners, for now. The bot checks
/// it too.
abstract final class WhatsAppPolicy {
  static bool canView(User user) => user.hasRole(GlobalRole.owner);
}

class GetBotAgent implements UseCase<BotAgent, NoParams> {
  const GetBotAgent(this._repository);

  final WhatsAppRepository _repository;

  @override
  Future<BotAgent> call(NoParams params) => _repository.getMe();
}

class GetTickets implements UseCase<List<Ticket>, TicketView> {
  const GetTickets(this._repository);

  final WhatsAppRepository _repository;

  @override
  Future<List<Ticket>> call(TicketView view) => _repository.getTickets(view);
}

class GetTicket implements UseCase<TicketDetail, String> {
  const GetTicket(this._repository);

  final WhatsAppRepository _repository;

  @override
  Future<TicketDetail> call(String ticketId) => _repository.getTicket(ticketId);
}

class TakeTicket implements UseCase<Ticket, String> {
  const TakeTicket(this._repository);

  final WhatsAppRepository _repository;

  @override
  Future<Ticket> call(String ticketId) => _repository.takeTicket(ticketId);
}

class CloseTicket implements UseCase<Ticket, String> {
  const CloseTicket(this._repository);

  final WhatsAppRepository _repository;

  @override
  Future<Ticket> call(String ticketId) => _repository.closeTicket(ticketId);
}

class ReplyParams {
  const ReplyParams({required this.ticketId, required this.body});

  final String ticketId;
  final String body;
}

/// Sends the trimmed text. Too long for WhatsApp is refused here
/// (`whatsapp.reply_too_long`), before calling the bot.
class ReplyToTicket implements UseCase<BotMessage, ReplyParams> {
  const ReplyToTicket(this._repository);

  final WhatsAppRepository _repository;

  @override
  Future<BotMessage> call(ReplyParams p) {
    final body = p.body.trim();
    if (body.length > maxReplyLength) {
      throw const RuleFailure('whatsapp.reply_too_long');
    }
    return _repository.reply(p.ticketId, body);
  }
}
