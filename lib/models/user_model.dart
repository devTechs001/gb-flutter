class UserModel {
  final String uid;
  final String phoneNumber;
  final String? displayName;
  final String? photoURL;
  final String? status;
  final String? about;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final List<String> contacts;
  final List<String> blockedUsers;
  final bool phoneVisible;
  final bool lastSeenVisible;
  final bool profilePhotoVisible;
  final bool statusVisible;
  final bool readReceipts;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.photoURL,
    this.status,
    this.about,
    this.isOnline = false,
    this.lastSeen,
    DateTime? createdAt,
    this.contacts = const [],
    this.blockedUsers = const [],
    this.phoneVisible = true,
    this.lastSeenVisible = true,
    this.profilePhotoVisible = true,
    this.statusVisible = true,
    this.readReceipts = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'phoneNumber': phoneNumber,
    'displayName': displayName,
    'photoURL': photoURL,
    'status': status ?? 'Hey there! I am using GB Chat',
    'about': about,
    'isOnline': isOnline,
    'lastSeen': lastSeen?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'contacts': contacts,
    'blockedUsers': blockedUsers,
    'phoneVisible': phoneVisible,
    'lastSeenVisible': lastSeenVisible,
    'profilePhotoVisible': profilePhotoVisible,
    'statusVisible': statusVisible,
    'readReceipts': readReceipts,
  };

  factory UserModel.fromMap(Map<String, dynamic> map, String id) => UserModel(
    uid: id,
    phoneNumber: map['phoneNumber'] ?? '',
    displayName: map['displayName'],
    photoURL: map['photoURL'],
    status: map['status'],
    about: map['about'],
    isOnline: map['isOnline'] ?? false,
    lastSeen: map['lastSeen'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'])
        : null,
    createdAt: map['createdAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
        : DateTime.now(),
    contacts: List<String>.from(map['contacts'] ?? []),
    blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    phoneVisible: map['phoneVisible'] ?? true,
    lastSeenVisible: map['lastSeenVisible'] ?? true,
    profilePhotoVisible: map['profilePhotoVisible'] ?? true,
    statusVisible: map['statusVisible'] ?? true,
    readReceipts: map['readReceipts'] ?? true,
  );

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
    String? status,
    String? about,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    List<String>? contacts,
    List<String>? blockedUsers,
    bool? phoneVisible,
    bool? lastSeenVisible,
    bool? profilePhotoVisible,
    bool? statusVisible,
    bool? readReceipts,
  }) => UserModel(
    uid: uid ?? this.uid,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    displayName: displayName ?? this.displayName,
    photoURL: photoURL ?? this.photoURL,
    status: status ?? this.status,
    about: about ?? this.about,
    isOnline: isOnline ?? this.isOnline,
    lastSeen: lastSeen ?? this.lastSeen,
    createdAt: createdAt ?? this.createdAt,
    contacts: contacts ?? this.contacts,
    blockedUsers: blockedUsers ?? this.blockedUsers,
    phoneVisible: phoneVisible ?? this.phoneVisible,
    lastSeenVisible: lastSeenVisible ?? this.lastSeenVisible,
    profilePhotoVisible: profilePhotoVisible ?? this.profilePhotoVisible,
    statusVisible: statusVisible ?? this.statusVisible,
    readReceipts: readReceipts ?? this.readReceipts,
  );
}
