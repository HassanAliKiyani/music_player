import 'package:flutter/material.dart';

class customSongTile extends StatelessWidget {
  final String songName;
  final String artistName;
  var trailing;
  final Function() onTap;
  var leading;

  customSongTile(
      {super.key,
      required this.songName,
      required this.artistName,
      required this.trailing,
      required this.onTap,
      this.leading});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(songName,
          style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold)),
      subtitle: Text(
        artistName,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      trailing: trailing,
      leading: leading ??
          Container(
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
          ),
    );
  }
}
