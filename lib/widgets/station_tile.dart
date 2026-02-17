import 'package:flutter/material.dart';
import '../models/station.dart';

class StationTile extends StatelessWidget {
  final Station station;
  final bool isPlaying;
  final VoidCallback onTap;

  const StationTile({
    super.key,
    required this.station,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        isPlaying ? Icons.play_circle_filled : Icons.radio,
        color: isPlaying ? theme.colorScheme.primary : null,
      ),
      title: Text(
        station.name,
        style: isPlaying
            ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
            : null,
      ),
      onTap: onTap,
    );
  }
}
