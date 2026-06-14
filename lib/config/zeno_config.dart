class ZenoConfig {
  static const String appName = 'ChatWave';
  static const String appVersion = '2.0.0';
  static const String backendUrl = 'http://localhost:3000';
  static const String socketUrl = 'http://localhost:3000';
  static const int maxBatchImages = 100;
  static const int maxBatchVideos = 50;
  static const int maxFileSizeMB = 100;
  static const int maxFileSize = maxFileSizeMB * 1024 * 1024;
  static const int messageCharacterLimit = 10000;

  static const String defaultStatus = 'Hey there! I am using ChatWave';
  static const String storageProfileImages = 'profile_images';
  static const String storageChatImages = 'chat_images';
  static const String storageChatVideos = 'chat_videos';
  static const String storageChatAudio = 'chat_audio';
  static const String storageChatDocuments = 'chat_documents';
  static const String storageStatusImages = 'status_images';
  static const String storageStatusVideos = 'status_videos';

  static const List<String> supportedFileTypes = [
    'apk', 'zip', 'rar', 'pdf', 'doc', 'docx',
    'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'mp3',
    'mp4', 'mkv', 'avi', 'gif', 'json', 'csv',
  ];
}
