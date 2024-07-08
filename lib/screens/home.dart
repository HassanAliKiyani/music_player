import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/components/custom_drawer.dart';
import 'package:music_player/models/playlistProvider.dart';
import 'package:music_player/screens/song_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../components/custom_songtile.dart';
import '../helpers/helper_functions.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Main method.
  // final OnAudioQuery audioQuery = OnAudioQuery();

  // Indicate if application has permission to the library.
  bool? _hasPermission;

  // @override
  // void initState() {
  //   super.initState();
  //   LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
  //   audioQuery.setLogConfig(logConfig);
  //   // Check and request for permission.
  //   checkAndRequestPermissions();
  // }

  @override
  void initState() {
    // Check and request for permission.
    Provider.of<PlaylistProvider>(context, listen: false)
        .initiatePlaylistProvider();


    super.initState();
  }

  void refreshSongs() {
    Provider.of<PlaylistProvider>(context, listen: false).fetchAllSongs();
  }

  // checkAndRequestPermissions({bool retry = false}) async {
  //   // The param 'retryRequest' is false, by default.
  //   _hasPermission = await audioQuery.checkAndRequest(
  //     retryRequest: retry,
  //   );
  //
  //   // Only call update the UI if application has all required permissions.
  //   _hasPermission ? setState(() {}) : null;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("P L A Y L I S T"),
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: FutureBuilder<bool>(
          future: Provider.of<PlaylistProvider>(context,listen: false).checkAndRequestPermissions(),
          builder: (context,snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if(snapshot.data == false){
              return noAccessToLibraryWidget();
            }
            Provider.of<PlaylistProvider>(context, listen: false).fetchAllSongs();
            return displaySongsProvider();
          },
        )
        // child: !_hasPermission!
        //     ? noAccessToLibraryWidget()
        //     : displaySongsProvider(),
      ),
    );
  }

  Consumer<PlaylistProvider> displaySongsProvider() {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
              if (value.allSongs.length == 0) {
                return const Text("Nothing found!");
              }
              List<SongModel> songs = value.allSongs;
              return ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  SongModel song = songs[index];
                  print(song.toString());
                  return customSongTile(
                    songName: song.title,
                    artistName: song.artist ?? "Unknown Artist",
                    onTap: () {
                      print("router->push->Playlist->SongScreen");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SongScreen(
                                    song: song,
                                    audioQuery: value.audioController,
                                  )));
                    },
                    trackLength:
                        formatMilliseconds(song.duration ?? 0).toString(),
                    leading: QueryArtworkWidget(
                      controller: value.audioController,
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget: nullArtWorkWidget(),
                    ),
                  );
                },
              );
            });
  }

  // FutureBuilder<List<SongModel>> displaySongsFuture(BuildContext context) {
  //   return FutureBuilder<List<SongModel>>(
  //       future: Provider.of<PlaylistProvider>(context).songs(),
  //       builder: (context, item) {
  //         if (item.hasError) {
  //           return Text(item.error.toString());
  //         }
  //         // Waiting content.
  //         if (item.data == null) {
  //           return const CircularProgressIndicator();
  //         }
  //         // 'Library' is empty.
  //         if (item.data!.isEmpty) return const Text("Nothing found!");
  //         List<SongModel> songs = item.data!;
  //         return ListView.builder(
  //           itemCount: songs.length,
  //           itemBuilder: (context, index) {
  //             SongModel song = songs[index];
  //             print(song.toString());
  //             return customSongTile(
  //               songName: song.title,
  //               artistName: song.artist ?? "Unknown Artist",
  //               onTap: () {
  //                 print("router->push->Playlist->SongScreen");
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => SongScreen(
  //                               song: song,
  //                               audioQuery: audioQuery,
  //                             )));
  //               },
  //               trackLength: formatMilliseconds(song.duration ?? 0).toString(),
  //               leading: QueryArtworkWidget(
  //                 controller: audioQuery,
  //                 id: song.id,
  //                 type: ArtworkType.AUDIO,
  //                 nullArtworkWidget: nullArtWorkWidget(),
  //               ),
  //             );
  //           },
  //         );
  //       });
  // }

  Widget nullArtWorkWidget() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        boxShadow: [
          BoxShadow(
              offset: Offset(1, 4),
              color: Theme.of(context).colorScheme.primary,
              blurRadius: 8)
        ],
      ),
      child: const Icon(
        Icons.music_note,
      ),
    );
  }

  Widget noAccessToLibraryWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.surface),
        boxShadow: [
          BoxShadow(
              offset: Offset(1, 4),
              color: Theme.of(context).colorScheme.primary,
              blurRadius: 8)
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Application doesn't have access to the library",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 8),
            onPressed: () => {Provider.of(context,listen: false).checkAndRequestPermissions(retry: true)},
            child: Text(
              "Allow",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );
  }
}
