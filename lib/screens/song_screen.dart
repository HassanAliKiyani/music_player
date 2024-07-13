import 'package:flutter/material.dart';
import 'package:music_player/components/custom_shadow_box.dart';
import 'package:music_player/models/playlistProvider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../helpers/helper_functions.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Bar
            SizedBox(
              height: 80,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  const Text(
                    "Now Playing",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  // LottieBuilder.network(
                  //   "https://lottie.host/1b2a5389-7c21-470c-bf86-c06a6bfa8f9c/5emnVxfP7H.json",
                  //   width: 50,
                  //   height: 50,
                  // ),
                  Lottie.asset("asset/animation/musicanimation.json",
                      width: 40, height: 40),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        // showScaffoldMessage(context: context, message: "Equilizer is coming soon");
                        showBottomCenteredMessage(context, "Hosla kis chez ki jaldi ha");
                      },
                      icon: Icon(Icons.equalizer)),
                ],
              ),
            ),
            // Album
            Expanded(
              flex: 2,
              child: CustomShadowBox(
                swipeWidget: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.85,
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Team is working on lyrics stay tuned"),
                            const SizedBox(
                              width: 8,
                            ),
                            Lottie.asset("asset/animation/loaderAnimation.json",
                                width: 40, height: 40),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                child: ValueListenableBuilder<int?>(
                  valueListenable: playlistProvider.currentSongIndexNotifier,
                  builder: (context, currentIndex, child) {
                    if (currentIndex == null) return SizedBox.shrink();
                    final currentSong = playlistProvider.allSongs[currentIndex];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QueryArtworkWidget(
                          controller: playlistProvider.audioQuery,
                          id: currentSong.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: LottieBuilder.asset(
                            "asset/animation/play_animation.json",
                            width: 250,
                            height: 250,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.85,
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                          ),
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
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Slider
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 35),
                    child: ValueListenableBuilder<Duration>(
                      valueListenable: playlistProvider.currentDurationNotifier,
                      builder: (context, currentDuration, child) {
                        return SliderTheme(
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
                            min: Duration.zero.inSeconds.toDouble(),
                            max: playlistProvider.totalDuration.inSeconds
                                .toDouble(),
                            value: currentDuration.inSeconds.toDouble(),
                            onChanged: (double newValue) {},
                            onChangeEnd: (double newValue) {
                              playlistProvider
                                  .seek(Duration(seconds: newValue.toInt()));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Duration Text
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, bottom: 35),
                    child: ValueListenableBuilder<Duration>(
                      valueListenable: playlistProvider.currentDurationNotifier,
                      builder: (context, currentDuration, child) {
                        return Row(
                          children: [
                            Text(formatMilliseconds(
                                currentDuration.inMilliseconds)),
                            Spacer(),
                            Text(formatMilliseconds(playlistProvider
                                    .allSongs[
                                        playlistProvider.currentSongIndex!]
                                    .duration ??
                                0)),
                          ],
                        );
                      },
                    ),
                  ),
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ValueListenableBuilder<bool>(
                          valueListenable: playlistProvider.playRandomNotifier,
                          builder: (context, playRandom, child) {
                            return IconButton(
                              icon: Icon(Icons.shuffle,
                                  color: playRandom
                                      ? Colors.green
                                      : Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                              onPressed: () {
                                // print(playlistProvider.playRandomSong);
                                playlistProvider.playRandomNotifier.value =
                                    !playlistProvider.playRandomNotifier.value;
                              },
                            );
                          }),
                      IconButton(
                        icon: Icon(Icons.skip_previous,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            size: 36),
                        onPressed: playlistProvider.playPreviousTrack,
                      ),
                      CircleAvatar(
                        radius: 32,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: playlistProvider.isPlayingNotifier,
                          builder: (context, isPlaying, child) {
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                size: 32,
                              ),
                              onPressed: playlistProvider.pauseOrResume,
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            size: 36),
                        onPressed: playlistProvider.playNextTrack,
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: playlistProvider.playRepeatNotifier,
                          builder: (context, playRepeat, child) {
                            return IconButton(
                              icon: Icon(Icons.repeat,
                                  color: playRepeat
                                      ? Colors.green
                                      : Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                              onPressed: () {
                                playlistProvider.playRepeatNotifier.value =
                                    !playlistProvider.playRepeatNotifier.value;
                              },
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
