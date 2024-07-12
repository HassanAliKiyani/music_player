import 'package:flutter/material.dart';
import 'package:music_player/models/playlistProvider.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/screens/song_screen.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

    return ValueListenableBuilder<int?>(
      valueListenable: playlistProvider.currentSongIndexNotifier,
      builder: (context, currentSongIndex, child) {
        if (currentSongIndex == null) {
          return SizedBox.shrink(); // No song playing, return empty widget
        }
        
        final currentSong = playlistProvider.allSongs[currentSongIndex];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SongScreen()),
            );
          },
          child: Container(
            height: 100,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<Duration>(
                  valueListenable: playlistProvider.currentDurationNotifier,
                  builder: (context, currentDuration, child) {
                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6)
                      ),
                      child: Slider(
                        min: 0,
                        max: playlistProvider.totalDuration.inSeconds.toDouble(),
                        activeColor: Colors.green,
                        inactiveColor: Theme.of(context).colorScheme.inversePrimary,
                        value: currentDuration.inSeconds.toDouble(),
                        onChanged: (double value) {},
                        onChangeEnd: (double value) {
                          playlistProvider.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: QueryArtworkWidget(
                          controller: playlistProvider.audioController,
                          id: currentSong.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Icon(Icons.music_note),
                          size: 40,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentSong.artist ?? 'Unknown Artist',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        onPressed: playlistProvider.playPreviousTrack,
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: playlistProvider.isPlayingNotifier,
                        builder: (context, isPlaying, child) {
                          return IconButton(
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                            onPressed: playlistProvider.pauseOrResume,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        onPressed: playlistProvider.playNextTrack,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}