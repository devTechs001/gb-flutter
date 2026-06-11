class ContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isRegistered;
  final String? photoURL;
  final String? status;
  final bool isOnline;
  final DateTime? lastSeen;

  ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.isRegistered = false,
    this.photoURL,
    this.status,
    this.isOnline = false,
    this.lastSeen,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'isRegistered': isRegistered,
    'photoURL': photoURL,
    'status': status,
    'isOnline': isOnline,
    'lastSeen': lastSeen?.millisecondsSinceEpoch,
  };

  factory ContactModel.fromMap(Map<String, dynamic> map, String id) => ContactModel(
    id: id,
    name: map['name'] ?? '',
    phoneNumber: map['phoneNumber'] ?? '',
    isRegistered: map['isRegistered'] ?? false,
    photoURL: map['photoURL'],
    status: map['status'],
    isOnline: map['isOnline'] ?? false,
    lastSeen: map['lastSeen'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'])
        : null,
  );
}
