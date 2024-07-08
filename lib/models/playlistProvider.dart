import 'package:flutter/cupertino.dart';
import 'package:music_player/models/custom_songmodel.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistProvider extends ChangeNotifier{
    final List<CustomSongModel> _defaultPlaylist = [];
    List<SongModel> _allSongs = [];
    final OnAudioQuery audioQuery = OnAudioQuery();
    int? _currentSongIndex;


    //Get playlist and song index

    List<CustomSongModel> get defaultPlayList=> _defaultPlaylist;
    int? get currentSongIndex=> _currentSongIndex;
    List<SongModel> get allSongs=> _allSongs;

    OnAudioQuery get audioController => audioQuery;

    initiatePlaylistProvider(){
        LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
        audioQuery.setLogConfig(logConfig);
    }

    Future<bool> checkAndRequestPermissions({bool retry = false}) async {
        // The param 'retryRequest' is false, by default.
        return await audioQuery.checkAndRequest(
            retryRequest: retry,
        );
    }

    fetchAllSongs()async{
        _allSongs = await audioQuery.querySongs(
            sortType: null,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
        );
    }

    fetchSongs()async{
        List<SongModel> songsData = await audioQuery.querySongs(
            sortType: null,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
        );
    }

    Future<List<SongModel>> songs()async{
        return await audioQuery.querySongs(
            sortType: null,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
        );
    }
}