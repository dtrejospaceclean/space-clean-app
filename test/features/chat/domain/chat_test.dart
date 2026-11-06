import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/chat/domain/entities/chat.dart';

void main() {
  test("a message's first line becomes the title", () {
    const message = ChatMessageRef(
      id: 'm1',
      text: '  Restroom 3B is out of soap  \nCan someone bring a refill?',
    );
    expect(message.suggestedTitle, 'Restroom 3B is out of soap');
  });

  test('a long first line is cut to fit a title', () {
    final message = ChatMessageRef(id: 'm1', text: 'a' * 300);
    expect(message.suggestedTitle.length, ChatMessageRef.maxTitle);
    expect(message.suggestedTitle, endsWith('…'));
  });

  test("a channel's custom data says what it's about", () {
    final job = ChatChannelInfo.fromData({
      'name': 'Lobby deep clean',
      'kind': 'job',
      'clientId': 'c1',
      'jobId': 'j1',
    });
    expect(job.kind, ChatChannelKind.job);
    expect(job.clientId, 'c1');
    expect(job.jobId, 'j1');

    final direct = ChatChannelInfo.fromData({'kind': 'direct'});
    expect(direct.kind, ChatChannelKind.direct);
    expect(direct.clientId, isNull);

    expect(ChatChannelInfo.fromData({}).kind, ChatChannelKind.unknown);
  });
}
