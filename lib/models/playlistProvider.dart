import 'package:flutter/cupertino.dart';
import 'package:music_player/models/songs.dart';

class PlaylistProvider extends ChangeNotifier{
    final List<Songs> defaultPlaylist = [];
}