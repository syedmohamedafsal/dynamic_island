class MusicNotificationData {
  final String title;
  final String artist;
  final String albumArtBase64;
  final String packageName;

  MusicNotificationData({
    required this.title,
    required this.artist,
    required this.albumArtBase64,
    required this.packageName,
  });

  factory MusicNotificationData.fromMap(Map<dynamic, dynamic> map) {
    return MusicNotificationData(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      albumArtBase64: map['albumArt'] ?? '',
      packageName: map['packageName'] ?? '',
    );
  }
}
