import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/models/document.dart';

class ResearchPaperCard extends StatelessWidget {
  final Document document;
  final Function()? onPlay;
  final Function()? onDelete;
  final Function()? onDownload;
  final Function()? onOfflineToggle;
  final bool isPlaying;
  final bool isCached;

  const ResearchPaperCard({
    super.key,
    required this.document,
    this.onPlay,
    this.onDelete,
    this.onDownload,
    this.onOfflineToggle,
    this.isPlaying = false,
    this.isCached = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        document.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.download),
                          onPressed: onDownload,
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.trash2),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      document.uploadDate.toString().split(' ')[0],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(LucideIcons.file, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${document.pageCount} pages',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (document.summary != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    document.summary!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(isPlaying ? LucideIcons.pause : LucideIcons.play),
                  label: Text(isPlaying ? 'Pause TTS' : 'Play TTS'),
                  onPressed: onPlay,
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: Icon(isCached ? LucideIcons.check : LucideIcons.download),
                  label: Text(isCached ? 'Saved Offline' : 'Save Offline'),
                  onPressed: onOfflineToggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
