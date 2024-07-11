import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/custom_shadow_box.dart';
import 'package:music_player/models/playlistProvider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../helpers/helper_functions.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
      SongModel currentSong = value.allSongs[value.currentSongIndex!];
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //App Bar
                SizedBox(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back)),
                      Text("Now Playing"),
                      IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
                    ],
                  ),
                ),
                //Album
                Expanded(
                  flex: 2,
                  child: CustomShadowBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QueryArtworkWidget(
                          controller: value.audioQuery,
                          id: currentSong.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Icon(
                            Icons.music_note,
                            size: 250,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width * 0.85,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.85),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 45,
                                child: Text(
                                  currentSong.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              Text(
                                  currentSong.artist == '<unknown>'
                                      ? "Unknown Artist"
                                      : currentSong.artist ?? "Unknown Artist",
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      //Controllers
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 35),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10),
                            activeTrackColor: Colors.green,
                            inactiveTrackColor:
                                Theme.of(context).colorScheme.inversePrimary,
                            thumbColor: Colors.green,
                            overlayColor: Colors.green.withOpacity(0.2),
                          ),
                          child: Slider(
                            min: 0,
                            max: value.totalDuration.inSeconds.toDouble(),
                            value: value.currentDuration.inSeconds.toDouble(),
                            onChanged: (double newValue) {},
                            onChangeEnd: (double newValue) {
                              value.seek(Duration(seconds: newValue.toInt()));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 35),
                        child: Row(
                          children: [
                            Text(formatMilliseconds(
                                value.currentDuration.inMilliseconds)),
                            Spacer(),
                            Text(formatMilliseconds(currentSong.duration ?? 0)),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.shuffle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_previous,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                size: 36),
                            onPressed: value.playPreviousTrack,
                          ),
                          CircleAvatar(
                            radius: 32,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: IconButton(
                              icon: Icon(
                                  value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  size: 32),
                              onPressed: value.pauseOrResume,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                size: 36),
                            onPressed: value.playNextTrack,
                          ),
                          IconButton(
                            icon: Icon(Icons.repeat,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

// Widget nullArtWorkWidget(){
//   return Container(
//     padding: const EdgeInsets.all(12.0),
//     decoration: BoxDecoration(
//       color: Theme.of(context).colorScheme.surface,
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: Theme.of(context).colorScheme.primary),
//       boxShadow: [
//         BoxShadow(
//             offset: Offset(1, 4),
//             color: Theme.of(context).colorScheme.primary,
//             blurRadius: 8)
//       ],
//     ),
//     child: const Icon(
//       Icons.music_note,
//     ),
//   );
// }
}
