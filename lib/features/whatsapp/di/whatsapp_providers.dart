import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/whatsapp_remote_data_source.dart';
import '../data/repositories/whatsapp_repository_impl.dart';
import '../domain/repositories/whatsapp_repository.dart';
import '../domain/usecases/whatsapp_usecases.dart';

final whatsAppRepositoryProvider = Provider<WhatsAppRepository>(
  (ref) => WhatsAppRepositoryImpl(
    WhatsAppRemoteDataSource(ref.watch(botDioProvider)),
  ),
);

final getBotAgentProvider = Provider(
  (ref) => GetBotAgent(ref.watch(whatsAppRepositoryProvider)),
);
final getTicketsProvider = Provider(
  (ref) => GetTickets(ref.watch(whatsAppRepositoryProvider)),
);
final getTicketProvider = Provider(
  (ref) => GetTicket(ref.watch(whatsAppRepositoryProvider)),
);
final takeTicketProvider = Provider(
  (ref) => TakeTicket(ref.watch(whatsAppRepositoryProvider)),
);
final closeTicketProvider = Provider(
  (ref) => CloseTicket(ref.watch(whatsAppRepositoryProvider)),
);
final replyToTicketProvider = Provider(
  (ref) => ReplyToTicket(ref.watch(whatsAppRepositoryProvider)),
);
