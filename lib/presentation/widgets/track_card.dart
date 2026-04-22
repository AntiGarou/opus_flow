import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';

class TrackCard extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;

  const TrackCard({super.key, required this.track, this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitle =
        '${track.artist.name} • ${TrackSource.displayName(track.source)}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 140,
                height: 140,
                child: track.artworkUrl != null
                    ? CachedNetworkImage(
                        imageUrl: track.artworkUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.white54, size: 40),
    );
  }
}
