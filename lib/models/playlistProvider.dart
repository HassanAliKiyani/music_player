import 'package:flutter/cupertino.dart';
import 'package:music_player/models/custom_songmodel.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';

class PlaylistProvider extends ChangeNotifier {
  List<SongModel> _allSongs = [];
  List<SongModel> _filteredList = [];
  final OnAudioQuery audioQuery = OnAudioQuery();
  int? _currentSongIndex;

  //Getters
  int? get currentSongIndex => _currentSongIndex;
  List<SongModel> get allSongs => _allSongs;
  OnAudioQuery get audioController => audioQuery;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  List<SongModel> get filteredList => _filteredList;

  //Setters
  set currentSongIndex(int? index) {
    if (_currentSongIndex == index) {
      return;
    }
    _currentSongIndex = index;
    if (index != null) {
      play();
    }
  }

  /* AUDIO PLAYER SETTINGS */

  final _audioPlayer = AudioPlayer();

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;

  // constructor

  PlaylistProvider() {
    listenToDuration();
  }

  // Search Song

  void searchSong(String query) {
    if (query.isEmpty) {
      _filteredList = _allSongs;
      notifyListeners();
      return;
    } else {
      // print("this is called");
      _filteredList = _allSongs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            (song.artist?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
      notifyListeners();
    }
  }
  //Play Song

  void play() async {
    String pathToPlay = _allSongs[_currentSongIndex!].data!;
    await _audioPlayer.stop();
    try {
      await _audioPlayer.play(DeviceFileSource(pathToPlay));
    } catch (e) {
      print("Error playing audio: $e");
    }
    _isPlaying = true;
    notifyListeners();
  }

  //pause current song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  //Stop Song
  //Pause or Resume Track
  void pauseOrResume() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
    notifyListeners();
  }

  //seek to position
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  //Next Track
  void playNextTrack() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! + 1 > _allSongs.length) {
        currentSongIndex = 0;
      } else {
        currentSongIndex = _currentSongIndex! + 1;
      }
    }
  }

  //Previous Track
  void playPreviousTrack() async {
    if (_currentDuration.inSeconds < 3) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      if (_currentSongIndex != null) {
        if (_currentSongIndex! == 0) {
          currentSongIndex = _allSongs.length - 1;
        } else {
          currentSongIndex = currentSongIndex! - 1;
        }
      }
    }
  }
  //Random Track
  //Mark as Favourite

  //Listen to duration

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      playNextTrack();
    });
  }

  //Controller settings

  initiatePlaylistProvider() {
    LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
    audioQuery.setLogConfig(logConfig);
  }


  fetchAllSongs({SongSortType sort = SongSortType.TITLE}) async {
   
      _allSongs = await audioQuery.querySongs(
        sortType: sort,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: false,
      );
      _allSongs = _allSongs.where((song) {
        // Check if duration is not null and greater than or equal to 2 minutes
        return song.duration != null && song.duration! >= 120000;
      }).toList();
      _filteredList = _allSongs;
      notifyListeners();
    
  }

  fetchFavouriteSongs() async {
    //Update the allSongsList
    await audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }
}
