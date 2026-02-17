import 'package:flutter/material.dart';

class NowPlayingBar extends StatelessWidget {
  final String stationName;
  final String status;
  final bool loading;

  const NowPlayingBar({
    super.key,
    required this.stationName,
    required this.status,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: loading
          ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stationName.isEmpty ? 'Nothing playing' : stationName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (status.isNotEmpty)
                  Text(
                    status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
    );
  }
}
