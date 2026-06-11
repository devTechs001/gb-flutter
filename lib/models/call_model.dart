class CallModel {
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerPhoto;
  final String receiverId;
  final String receiverName;
  final String? receiverPhoto;
  final String type;
  final String status;
  final String direction;
  final DateTime timestamp;
  final int duration;

  CallModel({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerPhoto,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhoto,
    required this.type,
    required this.status,
    required this.direction,
    DateTime? timestamp,
    this.duration = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'callId': callId,
    'callerId': callerId,
    'callerName': callerName,
    'callerPhoto': callerPhoto,
    'receiverId': receiverId,
    'receiverName': receiverName,
    'receiverPhoto': receiverPhoto,
    'type': type,
    'status': status,
    'direction': direction,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'duration': duration,
  };

  factory CallModel.fromMap(Map<String, dynamic> map, String id) => CallModel(
    callId: id,
    callerId: map['callerId'] ?? '',
    callerName: map['callerName'] ?? '',
    callerPhoto: map['callerPhoto'],
    receiverId: map['receiverId'] ?? '',
    receiverName: map['receiverName'] ?? '',
    receiverPhoto: map['receiverPhoto'],
    type: map['type'] ?? 'audio',
    status: map['status'] ?? 'missed',
    direction: map['direction'] ?? 'incoming',
    timestamp: map['timestamp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
        : DateTime.now(),
    duration: map['duration'] ?? 0,
  );

  String get durationFormatted {
    final min = duration ~/ 60;
    final sec = duration % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}
