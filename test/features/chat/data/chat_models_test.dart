import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/chat/data/models/chat_models.dart';
import 'package:sp_cln_app/features/notifications/domain/entities/push_message.dart';

void main() {
  test('reads the chat credentials', () {
    final c = ChatModels.credentials({
      'apiKey': 'key',
      'userId': 'u1',
      'token': 'jwt',
      'expiresAt': '2026-10-23T12:00:00.000Z',
    });
    expect(c.apiKey, 'key');
    expect(c.userId, 'u1');
    expect(c.token, 'jwt');
    expect(c.expiresAt, DateTime.utc(2026, 10, 23, 12));
  });

  test('reads a channel, from its cid when type and id are missing', () {
    final full = ChatModels.channel({
      'cid': 'messaging:job-1',
      'type': 'messaging',
      'id': 'job-1',
    });
    expect(full.cid, 'messaging:job-1');

    final direct = ChatModels.channel({'cid': 'messaging:!members-abc'});
    expect(direct.type, 'messaging');
    expect(direct.id, '!members-abc');
  });

  test('reads a contact without a photo', () {
    final c = ChatModels.contact({
      'id': 'u2',
      'name': 'Bea Ruiz',
      'photoUrl': null,
      'roles': ['supervisor'],
    });
    expect(c.name, 'Bea Ruiz');
    expect(c.photoUrl, isNull);
  });

  test("a Stream Chat push carries its channel through a tap", () {
    final push = PushMessage.fromData(
      {
        'sender': 'stream.chat',
        'type': 'message.new',
        'channel_type': 'messaging',
        'channel_id': 'account-c1',
        'message_id': 'm1',
      },
      title: 'Bea Ruiz',
      body: 'On my way',
    );
    expect(push.source, PushSource.streamChat);
    expect(push.chatChannelId, 'account-c1');

    final again = PushMessage.fromData(push.data);
    expect(again.source, PushSource.streamChat);
    expect(again.chatChannelId, 'account-c1');
    expect(again.chatMessageId, 'm1');
  });

  test('only an untitled Stream Chat push about a conversation is drawn', () {
    const data = {
      'sender': 'stream.chat',
      'channel_type': 'messaging',
      'channel_id': 'job-1',
      'message_id': 'm1',
    };
    final drawn = untitledChatPush(
      data,
      hasNotification: false,
      title: 'New message',
    );
    expect(drawn?.title, 'New message');
    expect(drawn?.chatChannelId, 'job-1');
    expect(drawn?.data['sender'], 'stream.chat');

    // The phone shows it by itself.
    expect(
      untitledChatPush(data, hasNotification: true, title: 'New message'),
      isNull,
    );
    // Ours, or Stream's about no conversation.
    expect(
      untitledChatPush(
        const {'source': 'spclean', 'notificationId': 'n1'},
        hasNotification: false,
        title: 'New message',
      ),
      isNull,
    );
    expect(
      untitledChatPush(
        const {'sender': 'stream.chat'},
        hasNotification: false,
        title: 'New message',
      ),
      isNull,
    );
  });
}
