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
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final String? replyTo;
  final bool edited;
  final bool deleted;
  final DateTime timestamp;
  final DateTime? editedAt;
  final Map<String, bool> readBy;
  final Map<String, bool> deliveredTo;
  final List<Map<String, dynamic>> reactions;
  final bool isForwarded;
  final String? forwardedFrom;

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
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.replyTo,
    this.edited = false,
    this.deleted = false,
    DateTime? timestamp,
    this.editedAt,
    Map<String, bool>? readBy,
    Map<String, bool>? deliveredTo,
    List<Map<String, dynamic>>? reactions,
    this.isForwarded = false,
    this.forwardedFrom,
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
    'latitude': latitude,
    'longitude': longitude,
    'contactName': contactName,
    'contactPhone': contactPhone,
    'replyTo': replyTo,
    'edited': edited,
    'deleted': deleted,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'editedAt': editedAt?.millisecondsSinceEpoch,
    'readBy': readBy,
    'deliveredTo': deliveredTo,
    'reactions': reactions,
    'isForwarded': isForwarded,
    'forwardedFrom': forwardedFrom,
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
    duration: map['duration'],
    latitude: map['latitude'],
    longitude: map['longitude'],
    contactName: map['contactName'],
    contactPhone: map['contactPhone'],
    replyTo: map['replyTo'],
    edited: map['edited'] ?? false,
    deleted: map['deleted'] ?? false,
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
  );

  String toJson() => jsonEncode(toMap());
  factory MessageModel.fromJson(String source) => MessageModel.fromMap(jsonDecode(source), '');

  bool get isMedia => ['image', 'video', 'audio', 'document'].contains(type);
  bool get isLocation => type == 'location';
  bool get isContact => type == 'contact';
}
