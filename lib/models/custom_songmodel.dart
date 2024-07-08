class CustomSongModel {
  final String songName;
  final String songArtist;
  final String songAlbumArt;
  final String songDuration;
  final String songLastPlaytime;
  final String songPath;

  CustomSongModel(
      {required this.songName,
      required this.songArtist,
      required this.songAlbumArt,
      required this.songDuration,
      required this.songLastPlaytime,
      required this.songPath});
}
