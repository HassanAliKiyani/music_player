import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/components/custom_drawer.dart';
import 'package:music_player/screens/song_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../components/custom_songtile.dart';
import '../helpers/helper_functions.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Main method.
  final OnAudioQuery audioQuery = OnAudioQuery();

  // Indicate if application has permission to the library.
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    // (Optinal) Set logging level. By default will be set to 'WARN'.
    //
    // Log will appear on:
    //  * XCode: Debug Console
    //  * VsCode: Debug Console
    //  * Android Studio: Debug and Logcat Console
    LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
    audioQuery.setLogConfig(logConfig);

    // Check and request for permission.
    checkAndRequestPermissions();
  }

  checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    _hasPermission = await audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    // Only call update the UI if application has all required permissions.
    _hasPermission ? setState(() {}) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("P L A Y L I S T"),
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: !_hasPermission
            ? noAccessToLibraryWidget()
            : FutureBuilder<List<SongModel>>(
                future: audioQuery.querySongs(
                  sortType: null,
                  orderType: OrderType.ASC_OR_SMALLER,
                  uriType: UriType.EXTERNAL,
                  ignoreCase: true,
                ),
                builder: (context, item) {
                  if (item.hasError) {
                    return Text(item.error.toString());
                  }

                  // Waiting content.
                  if (item.data == null) {
                    return const CircularProgressIndicator();
                  }

                  // 'Library' is empty.
                  if (item.data!.isEmpty) return const Text("Nothing found!");
                  List<SongModel> songs = item.data!;
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
                                  builder: (context) => SongScreen(song: song,audioQuery: audioQuery,)));
                        },
                        trackLength: formatMilliseconds(song.duration?? 0).toString(),
                        leading: QueryArtworkWidget(
                          controller: audioQuery,
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: nullArtWorkWidget(),
                        ) ,
                      );
                    },
                  );
                }),
      ),
    );
  }

  Widget nullArtWorkWidget(){
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
            onPressed: () => checkAndRequestPermissions(retry: true),
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
