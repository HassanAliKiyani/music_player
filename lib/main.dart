import 'package:flutter/material.dart';
import 'package:music_player/screens/home.dart';
import 'package:music_player/themes/LightMode.dart';
import 'package:music_player/themes/ThemeProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (context)=>ThemeProvider(), child: const MyApp(), ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music Player",
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Home(),
    );
  }
}

