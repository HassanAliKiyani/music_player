import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:music_player/screens/settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
              child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.music_note,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  size: 80,
                ),
                SizedBox(height: 12,),
                Text("M U S I C  P L A Y E R")
              ],
            ),
          )),
          //Home Tile
          Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: ListTile(
              onTap: (){
                print("router->pop->drawer");
                Navigator.pop(context);
              },
              leading: Icon(
                Icons.home_filled,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: Text("H O M E"),
            ),
          ),

          //Volume Boosters

          //Settings Tile
          Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: ListTile(
              onTap: (){
                print("router->push->settingsscreen");
                Navigator.push(context, MaterialPageRoute(builder: (context)=> SettingsScreen()));

              },
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: Text("S E T T I N G S"),
            ),
          )
        ],
      ),
    );
  }
}
