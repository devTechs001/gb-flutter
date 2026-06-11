class AppConfig {
  static const String appName = 'GB Chat';
  static const String appVersion = '1.0.0';
  static const String backendUrl = 'http://localhost:3000';
  static const String socketUrl = 'http://localhost:3000';
  static const String firebaseUrl = 'https://gb-chat-default-rtdb.firebaseio.com';

  static const Duration messageTimestamp = Duration(minutes: 1);
  static const int maxGroupMembers = 256;
  static const int maxMessageLength = 4096;
  static const int statusExpiryHours = 24;
  static const int maxFileSize = 64;
  static const List<String> supportedLanguages = ['en', 'ar'];

  static const String defaultStatus = 'Hey there! I am using GB Chat';
  static const String storageStatusImages = 'status_images';
  static const String storageProfileImages = 'profile_images';
  static const String storageChatImages = 'chat_images';
  static const String storageChatVideos = 'chat_videos';
  static const String storageChatAudio = 'chat_audio';
  static const String storageChatDocuments = 'chat_documents';
}
