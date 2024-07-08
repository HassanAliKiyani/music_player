import 'package:flutter/material.dart';
import 'package:music_player/components/custom_shadow_box.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

import '../helpers/helper_functions.dart';

class SongScreen extends StatefulWidget {
  final SongModel song;
  final OnAudioQuery audioQuery;

  const SongScreen({super.key, required this.song, required this.audioQuery});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {


  final player = AudioPlayer();

  bool isPlaying = false;

  //Play song
  void play()async{
    if(isPlaying){
      player.pause();
      setState(() {
        isPlaying = false;
      });
    }else {
      final duration = await player.setUrl( // Load a URL
          widget.song.data); // Schemes: (https: | file: | asset: )
      player.play();


      setState(() {
        isPlaying = true;
      });
    }
  }

  //Pause Running Track

  //Skip Forward

  //Skip Back

  //Next Track

  //Back Track


  @override
  Widget build(BuildContext context) {

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
                        // controller: widget.audioQuery,
                        id: widget.song.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Icon(
                          Icons.music_note,
                          size: 250,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width*0.85
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height:45,
                              child: Text(
                                widget.song.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            Text(
                                widget.song.artist == '<unknown>'
                                    ? "Unknown Artist"
                                    : widget.song.artist ?? "Unknown Artist",
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
                      padding: const EdgeInsets.only(
                          left: 40.0, right: 40, top: 30, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("00:00"),
                          Icon(Icons.shuffle),
                          Icon(Icons.repeat),
                          Text(formatMilliseconds(widget.song.duration ?? 0)),
                        ],
                      ),
                    ),
                    //Song track
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 6)),
                      child: Slider(
                          min: 0,
                          max: 100,
                          activeColor: Colors.green,
                          value: 50,
                          onChanged: (value) {}),
                    ),
                    //Playback controllers
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                            onTap: () {},
                            child: CustomShadowBox(
                              child: Icon(Icons.skip_previous),
                            ),
                          )),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () async {
                                  play();
                                },
                                child: CustomShadowBox(
                                  child: Icon(isPlaying? Icons.pause:Icons.play_arrow),
                                ),
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: GestureDetector(
                            onTap: () {},
                            child: CustomShadowBox(
                              child: Icon(Icons.skip_next),
                            ),
                          ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
