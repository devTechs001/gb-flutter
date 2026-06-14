class StatusModel {
  final String statusId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String mediaURL;
  final String? thumbnailURL;
  final String type;
  final String caption;
  final String? fontFamily;
  final int? backgroundColor;
  final DateTime timestamp;
  final DateTime expiresAt;
  final List<Map<String, dynamic>> viewers;
  final List<Map<String, dynamic>> reactions;
  final bool isMuted;
  final String? music;

  StatusModel({
    required this.statusId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.mediaURL,
    this.thumbnailURL,
    required this.type,
    this.caption = '',
    this.fontFamily,
    this.backgroundColor,
    this.music,
    DateTime? timestamp,
    DateTime? expiresAt,
    List<Map<String, dynamic>>? viewers,
    List<Map<String, dynamic>>? reactions,
    this.isMuted = false,
  })  : timestamp = timestamp ?? DateTime.now(),
        expiresAt = expiresAt ?? DateTime.now().add(Duration(hours: 24)),
        viewers = viewers ?? [],
        reactions = reactions ?? [];

  Map<String, dynamic> toMap() => {
    'statusId': statusId,
    'userId': userId,
    'userName': userName,
    'userPhoto': userPhoto,
    'mediaURL': mediaURL,
    'thumbnailURL': thumbnailURL,
    'type': type,
    'caption': caption,
    'fontFamily': fontFamily,
    'backgroundColor': backgroundColor,
    'music': music,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'expiresAt': expiresAt.millisecondsSinceEpoch,
    'viewers': viewers,
    'isMuted': isMuted,
  };

  factory StatusModel.fromMap(Map<String, dynamic> map, String id) => StatusModel(
    statusId: id,
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    userPhoto: map['userPhoto'],
    mediaURL: map['mediaURL'] ?? '',
    thumbnailURL: map['thumbnailURL'],
    type: map['type'] ?? 'image',
    caption: map['caption'] ?? '',
    fontFamily: map['fontFamily'],
    backgroundColor: map['backgroundColor'],
    music: map['music'],
    timestamp: map['timestamp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
        : DateTime.now(),
    expiresAt: map['expiresAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt'])
        : DateTime.now().add(Duration(hours: 24)),
    viewers: List<Map<String, dynamic>>.from(map['viewers'] ?? []),
    isMuted: map['isMuted'] ?? false,
  );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get viewCount => viewers.length;
}
