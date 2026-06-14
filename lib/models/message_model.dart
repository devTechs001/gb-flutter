import 'dart:convert';

class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderPhotoURL;
  final String type;
  final String content;
  final String? mediaURL;
  final String? thumbnailURL;
  final String? fileName;
  final int? fileSize;
  final double? duration;
  final List<double>? waveform;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final String? replyTo;
  final String? replySender;
  final String? replyContent;
  final String? replyType;
  final bool edited;
  final bool deleted;
  final bool isStarred;
  final DateTime timestamp;
  final DateTime? editedAt;
  final Map<String, bool> readBy;
  final Map<String, bool> deliveredTo;
  final List<Map<String, dynamic>> reactions;
  final bool isForwarded;
  final String? forwardedFrom;
  final String? linkPreviewUrl;
  final String? linkPreviewTitle;
  final String? linkPreviewDescription;
  final String? linkPreviewImage;
  final String? pollId;
  final String? pollQuestion;
  final List<Map<String, dynamic>>? pollOptions;
  final Map<String, List<String>>? pollVotes;
  final bool? pollMultiple;
  final DateTime? pollExpiry;
  final String? messageEffect;

  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoURL,
    required this.type,
    required this.content,
    this.mediaURL,
    this.thumbnailURL,
    this.fileName,
    this.fileSize,
    this.duration,
    this.waveform,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.replyTo,
    this.replySender,
    this.replyContent,
    this.replyType,
    this.edited = false,
    this.deleted = false,
    this.isStarred = false,
    DateTime? timestamp,
    this.editedAt,
    Map<String, bool>? readBy,
    Map<String, bool>? deliveredTo,
    List<Map<String, dynamic>>? reactions,
    this.isForwarded = false,
    this.forwardedFrom,
    this.linkPreviewUrl,
    this.linkPreviewTitle,
    this.linkPreviewDescription,
    this.linkPreviewImage,
    this.pollId,
    this.pollQuestion,
    this.pollOptions,
    this.pollVotes,
    this.pollMultiple,
    this.pollExpiry,
    this.messageEffect,
  })  : timestamp = timestamp ?? DateTime.now(),
        readBy = readBy ?? {},
        deliveredTo = deliveredTo ?? {},
        reactions = reactions ?? [];

  Map<String, dynamic> toMap() => {
    'messageId': messageId,
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'senderPhotoURL': senderPhotoURL,
    'type': type,
    'content': content,
    'mediaURL': mediaURL,
    'thumbnailURL': thumbnailURL,
    'fileName': fileName,
    'fileSize': fileSize,
    'duration': duration,
    'waveform': waveform,
    'latitude': latitude,
    'longitude': longitude,
    'contactName': contactName,
    'contactPhone': contactPhone,
    'replyTo': replyTo,
    'replySender': replySender,
    'replyContent': replyContent,
    'replyType': replyType,
    'edited': edited,
    'deleted': deleted,
    'isStarred': isStarred,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'editedAt': editedAt?.millisecondsSinceEpoch,
    'readBy': readBy,
    'deliveredTo': deliveredTo,
    'reactions': reactions,
    'isForwarded': isForwarded,
    'forwardedFrom': forwardedFrom,
    'linkPreviewUrl': linkPreviewUrl,
    'linkPreviewTitle': linkPreviewTitle,
    'linkPreviewDescription': linkPreviewDescription,
    'linkPreviewImage': linkPreviewImage,
    'pollId': pollId,
    'pollQuestion': pollQuestion,
    'pollOptions': pollOptions,
    'pollVotes': pollVotes,
    'pollMultiple': pollMultiple,
    'pollExpiry': pollExpiry?.millisecondsSinceEpoch,
    'messageEffect': messageEffect,
  };

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) => MessageModel(
    messageId: id,
    chatId: map['chatId'] ?? '',
    senderId: map['senderId'] ?? '',
    senderName: map['senderName'] ?? '',
    senderPhotoURL: map['senderPhotoURL'],
    type: map['type'] ?? 'text',
    content: map['content'] ?? '',
    mediaURL: map['mediaURL'],
    thumbnailURL: map['thumbnailURL'],
    fileName: map['fileName'],
    fileSize: map['fileSize'],
    duration: map['duration']?.toDouble(),
    waveform: map['waveform'] != null ? List<double>.from(map['waveform']) : null,
    latitude: map['latitude']?.toDouble(),
    longitude: map['longitude']?.toDouble(),
    contactName: map['contactName'],
    contactPhone: map['contactPhone'],
    replyTo: map['replyTo'],
    replySender: map['replySender'],
    replyContent: map['replyContent'],
    replyType: map['replyType'],
    edited: map['edited'] ?? false,
    deleted: map['deleted'] ?? false,
    isStarred: map['isStarred'] ?? false,
    timestamp: map['timestamp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
        : DateTime.now(),
    editedAt: map['editedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['editedAt'])
        : null,
    readBy: Map<String, bool>.from(map['readBy'] ?? {}),
    deliveredTo: Map<String, bool>.from(map['deliveredTo'] ?? {}),
    reactions: List<Map<String, dynamic>>.from(map['reactions'] ?? []),
    isForwarded: map['isForwarded'] ?? false,
    forwardedFrom: map['forwardedFrom'],
    linkPreviewUrl: map['linkPreviewUrl'],
    linkPreviewTitle: map['linkPreviewTitle'],
    linkPreviewDescription: map['linkPreviewDescription'],
    linkPreviewImage: map['linkPreviewImage'],
    pollId: map['pollId'],
    pollQuestion: map['pollQuestion'],
    pollOptions: map['pollOptions'] != null ? List<Map<String, dynamic>>.from(map['pollOptions']) : null,
    pollVotes: map['pollVotes'] != null ? Map<String, List<String>>.from(map['pollVotes']) : null,
    pollMultiple: map['pollMultiple'],
    pollExpiry: map['pollExpiry'] != null ? DateTime.fromMillisecondsSinceEpoch(map['pollExpiry']) : null,
    messageEffect: map['messageEffect'],
  );

  String toJson() => jsonEncode(toMap());
  factory MessageModel.fromJson(String source) => MessageModel.fromMap(jsonDecode(source), '');

  bool get isMedia => ['image', 'video', 'audio', 'document'].contains(type);
  bool get isLocation => type == 'location';
  bool get isContact => type == 'contact';
  bool get isPoll => type == 'poll';
  bool get isLinkPreview => linkPreviewUrl != null;
  bool get isVoice => type == 'voice';
}

class MessageEffectType {
  static const String confetti = 'confetti';
  static const String fireworks = 'fireworks';
  static const String hearts = 'hearts';
  static const String like = 'like';
  static const String none = 'none';
}
