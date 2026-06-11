class ChatModel {
  final String chatId;
  final String type;
  final List<String> participants;
  final String? groupName;
  final String? groupPhoto;
  final String? groupDescription;
  final String? groupAdmin;
  final String lastMessage;
  final String? lastMessageSender;
  final String? lastMessageType;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final Map<String, int> unreadCount;
  final Map<String, bool> mutedBy;
  final Map<String, bool> pinnedBy;
  final Map<String, bool> archivedBy;
  final bool isBroadcast;
  final String? broadcastName;

  ChatModel({
    required this.chatId,
    required this.type,
    required this.participants,
    this.groupName,
    this.groupPhoto,
    this.groupDescription,
    this.groupAdmin,
    this.lastMessage = '',
    this.lastMessageSender,
    this.lastMessageType,
    this.lastMessageTime,
    DateTime? createdAt,
    Map<String, int>? unreadCount,
    Map<String, bool>? mutedBy,
    Map<String, bool>? pinnedBy,
    Map<String, bool>? archivedBy,
    this.isBroadcast = false,
    this.broadcastName,
  })  : createdAt = createdAt ?? DateTime.now(),
        unreadCount = unreadCount ?? {},
        mutedBy = mutedBy ?? {},
        pinnedBy = pinnedBy ?? {},
        archivedBy = archivedBy ?? {};

  Map<String, dynamic> toMap() => {
    'chatId': chatId,
    'type': type,
    'participants': participants,
    'groupName': groupName,
    'groupPhoto': groupPhoto,
    'groupDescription': groupDescription,
    'groupAdmin': groupAdmin,
    'lastMessage': lastMessage,
    'lastMessageSender': lastMessageSender,
    'lastMessageType': lastMessageType,
    'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'unreadCount': unreadCount,
    'mutedBy': mutedBy,
    'pinnedBy': pinnedBy,
    'archivedBy': archivedBy,
    'isBroadcast': isBroadcast,
    'broadcastName': broadcastName,
  };

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) => ChatModel(
    chatId: id,
    type: map['type'] ?? 'individual',
    participants: List<String>.from(map['participants'] ?? []),
    groupName: map['groupName'],
    groupPhoto: map['groupPhoto'],
    groupDescription: map['groupDescription'],
    groupAdmin: map['groupAdmin'],
    lastMessage: map['lastMessage'] ?? '',
    lastMessageSender: map['lastMessageSender'],
    lastMessageType: map['lastMessageType'],
    lastMessageTime: map['lastMessageTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
        : null,
    createdAt: map['createdAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
        : DateTime.now(),
    unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    mutedBy: Map<String, bool>.from(map['mutedBy'] ?? {}),
    pinnedBy: Map<String, bool>.from(map['pinnedBy'] ?? {}),
    archivedBy: Map<String, bool>.from(map['archivedBy'] ?? {}),
    isBroadcast: map['isBroadcast'] ?? false,
    broadcastName: map['broadcastName'],
  );

  bool get isGroup => type == 'group';
  String get displayName => isGroup ? (groupName ?? 'Unnamed Group') : '';
  String get displayPhoto => isGroup ? (groupPhoto ?? '') : '';
}
