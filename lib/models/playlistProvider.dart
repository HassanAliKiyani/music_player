import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:music_player/models/custom_songmodel.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class PlaylistProvider extends ChangeNotifier {
  List<SongModel> _allSongs = [];
  List<SongModel> _filteredList = [];
  final OnAudioQuery audioQuery = OnAudioQuery();
  int? _currentSongIndex;

  //Lyrics API
  //https://api.lyrics.ovh/suggest/Coke%20Studio%20Season%2010%20Baazi__sahir_ALi_Bagga__Aima_Baig
  //https://api.lyrics.ovh/v1/ARTIST_NAME/SONG_NAME

  //Value Notifiers
  final ValueNotifier<List<SongModel>> overlappingSongsNotifier =
      ValueNotifier([]);
  final ValueNotifier<int?> currentSongIndexNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> playRandomNotifier = ValueNotifier(false);
  final ValueNotifier<bool> playRepeatNotifier = ValueNotifier(false);
  final ValueNotifier<Duration> currentDurationNotifier =
      ValueNotifier(Duration.zero);

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
      currentSongIndexNotifier.value = _currentSongIndex;
      return;
    }
    _currentSongIndex = index;
    if (index != null) {
      play();
    }
    currentSongIndexNotifier.value = index;
  }


  /* S O N G S _ Q U E R Y */

  List<SongModel> getOverlappingSongs() {
    return _allSongs.where((song) => _filteredList.contains(song)).toList();
  }

  void _updateOverlappingSongs() {
    overlappingSongsNotifier.value = getOverlappingSongs();
  }

  // Search Song
  void searchSong(String query) {
    if (query.isEmpty) {
      _filteredList = _allSongs;
      notifyListeners();
    } else {
      // print("this is called");
      _filteredList = _allSongs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            (song.artist?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
      notifyListeners();
    }
    _updateOverlappingSongs();
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
    _updateOverlappingSongs();
    notifyListeners();
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

  /* T R A C K _ C O N T R O L L E R S*/
  //Listen to duration
void listenToDuration() {
  _audioPlayer.onDurationChanged.listen((newDuration) {
    _totalDuration = newDuration;
    notifyListeners();
  });

  _audioPlayer.onPositionChanged.listen((newPosition) {
    // Ensure current duration does not exceed total duration
    if (newPosition > _totalDuration) {
      newPosition = _totalDuration;
    }
    _currentDuration = newPosition;
    currentDurationNotifier.value = newPosition;
    notifyListeners();
  });

  _audioPlayer.onPlayerComplete.listen((event) {
    // print("Song completed");
    playNextTrack();
  });
}


  //Play song
  void play() async {
    String pathToPlay = _allSongs[_currentSongIndex!].data!;
    await _audioPlayer.stop();
    try {
      await _audioPlayer.play(DeviceFileSource(pathToPlay));
    } catch (e) {
      print("Error playing audio: $e");
    }
    _isPlaying = true;
    isPlayingNotifier.value = true;
    notifyListeners();
  }

  //pause current song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
    isPlayingNotifier.value = false;
  }

  //Stop Song
  //Pause or Resume Track
  void pauseOrResume() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
      isPlayingNotifier.value = false;
    } else {
      await _audioPlayer.resume();
      _isPlaying = true;
      isPlayingNotifier.value = true;
    }
    notifyListeners();
  }

  //seek to position
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  //Next Track
  void playNextTrack() async{
    if (_currentSongIndex != null) {
      if(playRepeatNotifier.value){
        play();
        return;
      }
      if (playRandomNotifier.value) {
        math.Random random = math.Random();
        int randomIndex = random.nextInt(_allSongs.length);
        // Ensure the random index is not the same as the current song index
        while (randomIndex == _currentSongIndex) {
          randomIndex = random.nextInt(_allSongs.length);
        }
        // Update the current song index and notifier with the random index
        currentSongIndex = randomIndex;
        currentSongIndexNotifier.value = randomIndex;
      } else {
        if (_currentSongIndex! + 1 >= _allSongs.length) {
          currentSongIndex = 0;
          currentSongIndexNotifier.value = 0;
        } else {
          currentSongIndex = _currentSongIndex! + 1;
          currentSongIndexNotifier.value = currentSongIndex;
        }
      }
    }
  }

  //Previous Track
  void playPreviousTrack() async {
    if (_currentDuration.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      if (_currentSongIndex != null) {
        if (_currentSongIndex! == 0) {
          currentSongIndex = _allSongs.length - 1;
          currentSongIndexNotifier.value = currentSongIndex;
        } else {
          currentSongIndex = currentSongIndex! - 1;
          currentSongIndexNotifier.value = currentSongIndex;
        }
      }
    }
  }
}
