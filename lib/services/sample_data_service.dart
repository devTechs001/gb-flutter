import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/call_model.dart';
import '../models/status_model.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/call_provider.dart';
import '../providers/status_provider.dart';
import '../services/local_storage_service.dart';

class SampleDataService {
  static final List<Map<String, dynamic>> _contacts = [
    {'name': 'Sarah Johnson', 'phone': '+1 (555) 123-4567', 'online': true, 'status': 'At the gym 🏋️'},
    {'name': 'Mike Chen', 'phone': '+1 (555) 234-5678', 'online': false, 'status': 'Busy working'},
    {'name': 'Emma Wilson', 'phone': '+1 (555) 345-6789', 'online': true, 'status': 'Coffee time ☕'},
    {'name': 'James Rodriguez', 'phone': '+1 (555) 456-7890', 'online': true, 'status': 'Available'},
    {'name': 'Priya Patel', 'phone': '+1 (555) 567-8901', 'online': false, 'status': 'In a meeting'},
    {'name': 'Alex Thompson', 'phone': '+1 (555) 678-9012', 'online': true, 'status': 'Coding 🚀'},
    {'name': 'Lisa Kim', 'phone': '+1 (555) 789-0123', 'online': false, 'status': 'On vacation ✈️'},
    {'name': 'David Brown', 'phone': '+1 (555) 890-1234', 'online': true, 'status': 'Hey there! I am using ChatWave'},
    {'name': 'ChatWave Group', 'phone': '', 'online': false, 'status': '', 'isGroup': true, 'groupName': 'ChatWave Team', 'groupDesc': 'ChatWave development team chat'},
    {'name': 'Family Circle', 'phone': '', 'online': false, 'status': '', 'isGroup': true, 'groupName': 'Family Circle', 'groupDesc': 'Family group'},
  ];

  static final List<List<Map<String, dynamic>>> _conversations = [
    // Sarah Johnson
    [
      {'sender': 'them', 'text': 'Hey! How are you?', 'time': -3600},
      {'sender': 'me', 'text': 'I\'m great! Just working on the new ChatWave app 🚀', 'time': -3500},
      {'sender': 'them', 'text': 'That sounds awesome! When can I try it?', 'time': -3400},
      {'sender': 'me', 'text': 'Soon! Adding some really cool features', 'time': -3300},
      {'sender': 'them', 'text': 'Can\'t wait! Let me know if you need beta testers', 'time': -3200},
      {'sender': 'me', 'text': 'Will do! Thanks Sarah 😊', 'time': -3100},
      {'sender': 'them', 'text': 'By the way, are you free this weekend?', 'time': -3000},
      {'sender': 'me', 'text': 'Yeah, should be! What\'s up?', 'time': -2900},
      {'sender': 'them', 'text': 'There\'s a new cafe downtown, thought we could check it out', 'time': -2800},
      {'sender': 'me', 'text': 'Sounds like a plan! Saturday afternoon?', 'time': -2700},
      {'sender': 'them', 'text': 'Perfect! I\'ll send you the address 🎉', 'time': -300},
      {'sender': 'me', 'text': 'Great, see you then!', 'time': -200},
    ],
    // Mike Chen
    [
      {'sender': 'me', 'text': 'Hey Mike, did you finish the report?', 'time': -7200},
      {'sender': 'them', 'text': 'Almost done! Just need to review the numbers', 'time': -7100},
      {'sender': 'me', 'text': 'Cool, when do you think you\'ll have it?', 'time': -7000},
      {'sender': 'them', 'text': 'By end of day for sure', 'time': -6900},
      {'sender': 'me', 'text': 'Perfect, no rush 👍', 'time': -6800},
      {'sender': 'them', 'text': 'Actually, can you take a look at page 3? Not sure about the stats', 'time': -1500},
      {'sender': 'me', 'text': 'Sure, send it over and I\'ll check', 'time': -1400},
      {'sender': 'them', 'text': 'Thanks! Just shared it with you', 'time': -1300},
    ],
    // Emma Wilson
    [
      {'sender': 'them', 'text': 'Good morning! ☀️', 'time': -18000},
      {'sender': 'me', 'text': 'Morning Emma! How was your trip?', 'time': -17900},
      {'sender': 'them', 'text': 'Amazing! The beach was incredible 🏖️', 'time': -17800},
      {'sender': 'them', 'text': 'I brought you a souvenir!', 'time': -17700},
      {'sender': 'me', 'text': 'Aww you shouldn\'t have! What is it?', 'time': -17600},
      {'sender': 'them', 'text': 'A secret 😄 I\'ll give it to you when we meet', 'time': -17500},
      {'sender': 'me', 'text': 'Now I\'m curious! Let\'s grab lunch this week', 'time': -17400},
      {'sender': 'them', 'text': 'Thursday works for me! Same place?', 'time': -600},
      {'sender': 'me', 'text': 'Perfect, see you at 1!', 'time': -500},
    ],
    // James Rodriguez
    [
      {'sender': 'them', 'text': 'Check out this cool new framework I found', 'time': -1800},
      {'sender': 'them', 'text': 'https://example.com/awesome-framework', 'time': -1790},
      {'sender': 'me', 'text': 'Interesting! What does it do?', 'time': -1700},
      {'sender': 'them', 'text': 'It\'s for building real-time apps super fast', 'time': -1600},
      {'sender': 'me', 'text': 'Looks promising, I\'ll check it out later', 'time': -1500},
      {'sender': 'them', 'text': 'We should use it for the next project!', 'time': -1400},
      {'sender': 'me', 'text': 'Maybe! Let me do some research first', 'time': -1300},
    ],
    // Priya Patel
    [
      {'sender': 'them', 'text': 'Happy Birthday!!! 🎂🎉', 'time': -86400},
      {'sender': 'me', 'text': 'Thank you Priya! 🥳', 'time': -86300},
      {'sender': 'them', 'text': 'Hope you have an amazing day!', 'time': -86200},
      {'sender': 'me', 'text': 'You\'re the best! Party this weekend 🎈', 'time': -86100},
      {'sender': 'them', 'text': 'I\'ll be there! Bringing my famous brownies 😋', 'time': -86000},
    ],
    // Alex Thompson
    [
      {'sender': 'me', 'text': 'How\'s the new project going?', 'time': -43200},
      {'sender': 'them', 'text': 'Really well! We\'re ahead of schedule', 'time': -43100},
      {'sender': 'me', 'text': 'That\'s great news! Any challenges?', 'time': -43000},
      {'sender': 'them', 'text': 'Just the usual deployment stuff', 'time': -42900},
      {'sender': 'me', 'text': 'Let me know if you need help with CI/CD', 'time': -42800},
      {'sender': 'them', 'text': 'Will do! Thanks for offering 🙌', 'time': -42700},
      {'sender': 'them', 'text': 'Actually, could you review my PR?', 'time': -900},
      {'sender': 'me', 'text': 'Sure, sending feedback now', 'time': -800},
    ],
    // Lisa Kim
    [
      {'sender': 'them', 'text': 'Guess what! I got the job! 🎉', 'time': -172800},
      {'sender': 'me', 'text': 'OMG CONGRATULATIONS!!! 🎊🎊🎊', 'time': -172700},
      {'sender': 'them', 'text': 'Thank you! Couldn\'t have done it without your help', 'time': -172600},
      {'sender': 'me', 'text': 'You earned it! When do you start?', 'time': -172500},
      {'sender': 'them', 'text': 'Next Monday! I\'m so excited 🚀', 'time': -172400},
      {'sender': 'me', 'text': 'Let\'s celebrate this weekend!', 'time': -172300},
      {'sender': 'them', 'text': 'Absolutely! Dinner\'s on me 🍕', 'time': -172200},
    ],
    // David Brown
    [
      {'sender': 'them', 'text': 'Hey, are you going to the conference next month?', 'time': -259200},
      {'sender': 'me', 'text': 'Yeah! Already got my tickets', 'time': -259100},
      {'sender': 'them', 'text': 'Awesome! Let\'s go together', 'time': -259000},
      {'sender': 'me', 'text': 'For sure! I\'ll book us a hotel', 'time': -258900},
    ],
  ];

  static final List<List<Map<String, dynamic>>> _groupConversations = [
    // ChatWave Team
    [
      {'sender': 'them', 'text': 'Team, we have a deadline next week!', 'time': -14400, 'senderName': 'Alex Thompson'},
      {'sender': 'them', 'text': 'I\'ll have my part ready by Wednesday', 'time': -14300, 'senderName': 'Sarah Johnson'},
      {'sender': 'them', 'text': 'Same here, frontend is almost done', 'time': -14200, 'senderName': 'Mike Chen'},
      {'sender': 'me', 'text': 'Backend APIs are all tested and ready', 'time': -14100},
      {'sender': 'them', 'text': 'Great work team! 🔥 Let\'s crush this!', 'time': -14000, 'senderName': 'Alex Thompson'},
      {'sender': 'them', 'text': 'When\'s the next standup?', 'time': -600, 'senderName': 'Sarah Johnson'},
      {'sender': 'me', 'text': 'Tomorrow 10 AM as usual', 'time': -500},
    ],
    // Family Circle
    [
      {'sender': 'them', 'text': 'Who\'s coming to dinner on Sunday?', 'time': -7200, 'senderName': 'Mom'},
      {'sender': 'them', 'text': 'I\'ll be there! Bringing dessert 🍰', 'time': -7100, 'senderName': 'Lisa'},
      {'sender': 'them', 'text': 'Count me in too!', 'time': -7000, 'senderName': 'Dad'},
      {'sender': 'me', 'text': 'I\'ll come! What time?', 'time': -6900},
      {'sender': 'them', 'text': '6 PM as usual 😊', 'time': -6800, 'senderName': 'Mom'},
    ],
  ];

  static int _messageIdCounter = 0;
  static String _nextId() => 'sample_msg_${++_messageIdCounter}';

  static void loadSampleData(ChatProvider chatProvider, AuthProvider authProvider) {
    final uid = authProvider.userId;
    if (uid.isEmpty) return;

    final now = DateTime.now();
    final List<ChatModel> sampleChats = [];
    final Map<String, List<MessageModel>> sampleMessages = {};

    for (int i = 0; i < _contacts.length; i++) {
      final contact = _contacts[i];
      final isGroup = contact['isGroup'] == true;
      final chatId = isGroup ? 'group_${i}_${uid}' : '${[uid, 'user_${i}']..sort()}';
      final convos = isGroup
          ? _groupConversations[i >= _contacts.length - 2 ? i - (_contacts.length - 2) : 0]
          : (i < _conversations.length ? _conversations[i] : []);

      final messages = convos.asMap().entries.map((entry) {
        final msg = entry.value;
        final isMe = msg['sender'] == 'me';
        final timeOffset = (msg['time'] as int);
        final senderName = isMe
            ? (authProvider.userModel?.displayName ?? 'You')
            : (msg['senderName'] as String? ?? contact['name'] as String);
        final senderId = isMe ? uid : 'user_${i}';

        return MessageModel(
          messageId: _nextId(),
          chatId: chatId,
          senderId: senderId,
          senderName: senderName,
          type: 'text',
          content: msg['text'] as String,
          timestamp: now.add(Duration(seconds: timeOffset)),
          deliveredTo: {senderId: true},
          readBy: isMe ? {} : {uid: entry.key == convos.length - 1},
        );
      }).toList();

      sampleMessages[chatId] = messages;

      final lastMsg = messages.isNotEmpty ? messages.last : null;
      sampleChats.add(ChatModel(
        chatId: chatId,
        type: isGroup ? 'group' : 'individual',
        participants: isGroup ? [uid, 'user_${i}'] : [uid, 'user_${i}'],
        groupName: isGroup ? contact['groupName'] as String : null,
        groupDescription: isGroup ? contact['groupDesc'] as String : null,
        groupAdmin: isGroup ? uid : null,
        lastMessage: lastMsg?.content ?? '',
        lastMessageSender: lastMsg != null && lastMsg.senderId == uid ? null : (lastMsg?.senderName ?? ''),
        lastMessageType: 'text',
        lastMessageTime: lastMsg?.timestamp,
        unreadCount: {uid: i == 1 ? 2 : (i == 4 ? 1 : 0)},
        mutedBy: {uid: i == 6},
        pinnedBy: {uid: i == 0 || i == 8},
      ));
    }

    chatProvider.setSampleData(sampleChats, sampleMessages);
  }

  static void loadSampleCalls(CallProvider callProvider, AuthProvider authProvider) {
    final uid = authProvider.userId;
    if (uid.isEmpty) return;
    final now = DateTime.now();

    final calls = [
      CallModel(
        callId: 'call_1', callerId: 'user_0', callerName: 'Sarah Johnson',
        receiverId: uid, receiverName: 'Me', type: 'video',
        status: 'answered', direction: 'incoming', timestamp: now.subtract(const Duration(hours: 2)), duration: 845,
      ),
      CallModel(
        callId: 'call_2', callerId: 'user_2', callerName: 'Emma Wilson',
        receiverId: uid, receiverName: 'Me', type: 'audio',
        status: 'missed', direction: 'incoming', timestamp: now.subtract(const Duration(hours: 5)),
      ),
      CallModel(
        callId: 'call_3', callerId: uid, callerName: 'Me',
        receiverId: 'user_1', receiverName: 'Mike Chen', type: 'audio',
        status: 'answered', direction: 'outgoing', timestamp: now.subtract(const Duration(days: 1)), duration: 320,
      ),
      CallModel(
        callId: 'call_4', callerId: 'user_3', callerName: 'James Rodriguez',
        receiverId: uid, receiverName: 'Me', type: 'video',
        status: 'answered', direction: 'incoming', timestamp: now.subtract(const Duration(days: 2)), duration: 1560,
      ),
      CallModel(
        callId: 'call_5', callerId: 'user_5', callerName: 'Alex Thompson',
        receiverId: uid, receiverName: 'Me', type: 'audio',
        status: 'missed', direction: 'incoming', timestamp: now.subtract(const Duration(days: 3)),
      ),
      CallModel(
        callId: 'call_6', callerId: uid, callerName: 'Me',
        receiverId: 'user_6', receiverName: 'Lisa Kim', type: 'video',
        status: 'answered', direction: 'outgoing', timestamp: now.subtract(const Duration(days: 4)), duration: 600,
      ),
    ];

    callProvider.setSampleCalls(calls);
  }

  static void loadSampleStatus(StatusProvider statusProvider, AuthProvider authProvider) {
    final uid = authProvider.userId;
    if (uid.isEmpty) return;
    final now = DateTime.now();

    final statuses = [
      StatusModel(
        statusId: 'status_1', userId: uid, userName: 'My Status',
        mediaURL: '', type: 'text',
        caption: 'Building something amazing! 🚀',
        backgroundColor: 0xFF128C7E,
        timestamp: now.subtract(const Duration(hours: 1)),
        viewers: [
          {'userId': 'user_0', 'userName': 'Sarah Johnson'},
          {'userId': 'user_2', 'userName': 'Emma Wilson'},
        ],
      ),
      StatusModel(
        statusId: 'status_2', userId: 'user_0', userName: 'Sarah Johnson',
        mediaURL: 'https://picsum.photos/id/64/400/700', type: 'image',
        caption: 'At the beach! 🌊',
        timestamp: now.subtract(const Duration(hours: 3)),
        viewers: [{'userId': uid, 'userName': 'Me'}],
      ),
      StatusModel(
        statusId: 'status_3', userId: 'user_2', userName: 'Emma Wilson',
        mediaURL: '', type: 'text',
        caption: 'Coffee time! ☕',
        backgroundColor: 0xFF34B7F1,
        timestamp: now.subtract(const Duration(hours: 5)),
        viewers: [{'userId': uid, 'userName': 'Me'}],
      ),
      StatusModel(
        statusId: 'status_4', userId: 'user_5', userName: 'Alex Thompson',
        mediaURL: 'https://picsum.photos/id/106/400/700', type: 'image',
        caption: 'Mountain view 🏔️',
        timestamp: now.subtract(const Duration(hours: 8)),
        viewers: [
          {'userId': uid, 'userName': 'Me'},
          {'userId': 'user_0', 'userName': 'Sarah Johnson'},
        ],
      ),
      StatusModel(
        statusId: 'status_5', userId: 'user_3', userName: 'James Rodriguez',
        mediaURL: '', type: 'text',
        caption: 'New framework dropped! 🔥',
        backgroundColor: 0xFF5856D6,
        timestamp: now.subtract(const Duration(hours: 12)),
        viewers: [{'userId': uid, 'userName': 'Me'}],
      ),
    ];

    statusProvider.setSampleStatuses(statuses);
  }
}
