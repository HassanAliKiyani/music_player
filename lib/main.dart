import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:music_player/models/playlistProvider.dart';
import 'package:music_player/screens/home.dart';
import 'package:music_player/themes/ThemeProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => PlaylistProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    // Provider.of<ThemeProvider>(context,listen: false).userTheme();
    return MaterialApp(
      title: "Music Player",
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Home(),
    );
  }
}
