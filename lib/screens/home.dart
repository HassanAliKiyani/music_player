import 'package:flutter/material.dart';
import 'package:music_player/components/custom_drawer.dart';
import 'package:music_player/components/now_playing_bar.dart';
import 'package:music_player/models/playlistProvider.dart';
import 'package:music_player/screens/song_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../components/custom_songtile.dart';
import '../helpers/helper_functions.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late OnAudioQuery audioQuery;
  late Future<bool> _permissionFuture;

  @override
  void initState() {
    super.initState();
    audioQuery =
        Provider.of<PlaylistProvider>(context, listen: false).audioController;
    _permissionFuture = checkAndRequestPermissions();
  }

  Future<bool> checkAndRequestPermissions({bool retry = false}) async {
    bool hasPermission = await audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    if (hasPermission) {
      refreshSongs();
    }

    return hasPermission;
  }


  Future<void> refreshSongs() async {
    await Provider.of<PlaylistProvider>(context, listen: false).fetchAllSongs();
    setState(() {}); // Trigger a rebuild after fetching songs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("P L A Y L I S T"),
        actions: [
          IconButton(
              onPressed: () {
                checkAndRequestPermissions(retry: true);
                Provider.of<PlaylistProvider>(context,listen: false).fetchAllSongs();
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      drawer: CustomDrawer(),
      body: FutureBuilder<bool>(
        future: _permissionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.data == true) {
            
            return SongListWidget();
          } else {
            return noAccessToLibraryWidget();
          }
        },
      ),
    );
  }

  // Widget displaySongsProvider() {
  //   return Consumer<PlaylistProvider>(
  //     builder: (context, value, child) {
  //       List<SongModel> songs = value.allSongs;
  //       return Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: TextField(
  //               onChanged: (query) {
  //                 value.searchSong(query);
  //               },
  //               decoration: InputDecoration(
  //                 labelText: 'Search',
  //                 border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(24)),
  //                 prefixIcon: Icon(Icons.search),
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: songs.isEmpty
  //                 ? Center(child: Text("Nothing found!"))
  //                 : ListView.builder(
  //                     itemCount: songs.length,
  //                     itemBuilder: (context, index) {
  //                       SongModel song = songs[index];
  //                       if (!value.filteredList.contains(song)) {
  //                         return SizedBox.shrink();
  //                       }
  //                       return customSongTile(
  //                         songName: song.title,
  //                         artistName: song.artist ?? "Unknown Artist",
  //                         onTap: () {
  //                           value.currentSongIndex = index;
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => const SongScreen(),
  //                             ),
  //                           );
  //                         },
  //                         trailing: Column(
  //                           children: [
  //                             index == value.currentSongIndex
  //                                 ? GestureDetector(
  //                                     onTap: value.pauseOrResume,
  //                                     child: Icon(value.isPlaying
  //                                         ? Icons.pause
  //                                         : Icons.play_arrow))
  //                                 : SizedBox.shrink(),
  //                             index == value.currentSongIndex
  //                                 ? Text(formatMilliseconds(value
  //                                             .currentDuration.inMilliseconds ??
  //                                         0)
  //                                     .toString())
  //                                 : Text(formatMilliseconds(song.duration ?? 0)
  //                                     .toString())
  //                           ],
  //                         ),
  //                         leading: QueryArtworkWidget(
  //                           controller: value.audioController,
  //                           id: song.id,
  //                           type: ArtworkType.AUDIO,
  //                           nullArtworkWidget: nullArtWorkWidget(),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //           ),
  //           const NowPlayingBar()
  //         ],
  //       );
  //     },
  //   );
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
            blurRadius: 8,
          )
        ],
      ),
      child: const Icon(Icons.music_note),
    );
  }

  Widget noAccessToLibraryWidget() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.surface),
          boxShadow: [
            BoxShadow(
              offset: Offset(1, 4),
              color: Theme.of(context).colorScheme.primary,
              blurRadius: 8,
            )
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
                elevation: 8,
              ),
              onPressed: () async {
                bool hasPermission =
                    await checkAndRequestPermissions(retry: true);
                if (hasPermission) {
                  setState(() {
                    _permissionFuture = Future.value(true);
                  });
                }
              },
              child: Text(
                "Allow",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongListWidget extends StatefulWidget {
  @override
  State<SongListWidget> createState() => _SongListWidgetState();
}

class _SongListWidgetState extends State<SongListWidget> {
  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (query) {
              playlistProvider.searchSong(query);
            },
            decoration: InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<SongModel>>(
            valueListenable: playlistProvider.overlappingSongsNotifier,
            builder: (context, songs, child) {
              return songs.isEmpty
                  ? Center(child: Text("Nothing found!"))
                  : ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        SongModel song = songs[index];
                        return customSongTile(
                          songName: song.title,
                          artistName: song.artist ?? "Unknown Artist",
                          onTap: () {
                            playlistProvider.currentSongIndex = playlistProvider.allSongs.indexOf(song);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SongScreen(),
                              ),
                            );
                          },
                          trailing: Column(
                            children: [
                              ValueListenableBuilder<int?>(
                                valueListenable: playlistProvider.currentSongIndexNotifier,
                                builder: (context, currentIndex, child) {
                                  return index == currentIndex
                                      ? GestureDetector(
                                          onTap: playlistProvider.pauseOrResume,
                                          child: ValueListenableBuilder<bool>(
                                            valueListenable: playlistProvider.isPlayingNotifier,
                                            builder: (context, isPlaying, child) {
                                              return Icon(isPlaying ? Icons.pause : Icons.play_arrow);
                                            },
                                          ),
                                        )
                                      : SizedBox.shrink();
                                },
                              ),
                              ValueListenableBuilder<Duration>(
                                valueListenable: playlistProvider.currentDurationNotifier,
                                builder: (context, currentDuration, child) {
                                  return Text(
                                    index == playlistProvider.currentSongIndex
                                        ? formatMilliseconds(currentDuration.inMilliseconds)
                                        : formatMilliseconds(song.duration ?? 0),
                                  );
                                },
                              ),
                            ],
                          ),
                          leading: QueryArtworkWidget(
                            controller: playlistProvider.audioController,
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: nullArtWorkWidget(),
                          ),
                        );
                      },
                    );
            },
          ),
        ),
        const NowPlayingBar()
      ],
    );
  }

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
            blurRadius: 8,
          )
        ],
      ),
      child: const Icon(Icons.music_note),
    );
  }
}