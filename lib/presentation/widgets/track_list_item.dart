import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/playback_state.dart';
import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';
import '../bloc/library/library_cubit.dart';
import '../bloc/player/player_cubit.dart';

class TrackListItem extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onDownload;

  const TrackListItem({
    super.key,
    required this.track,
    this.onTap,
    this.onAddToPlaylist,
    this.onDownload,
  });

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString();
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<PlayerCubit, PlaybackState>(
      builder: (context, player) {
        final isCurrent = player.currentTrack?.id == track.id;
        return BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, library) {
            final isFav =
                library.favorites.any((t) => t.id == track.id);
            return ListTile(
              onTap: onTap,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: track.artworkUrl != null
                      ? CachedNetworkImage(
                          imageUrl: track.artworkUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _placeholder(scheme),
                          errorWidget: (_, __, ___) => _placeholder(scheme),
                        )
                      : _placeholder(scheme),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent
                            ? scheme.primary
                            : scheme.onSurface,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Icon(Icons.graphic_eq_rounded,
                        color: scheme.primary, size: 16)
                  else
                    Text(
                      _formatDuration(track.duration),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                '${track.artist.name} • ${TrackSource.displayName(track.source)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    onPressed: () =>
                        context.read<LibraryCubit>().toggleFavorite(track),
                  ),
                  if (onAddToPlaylist != null)
                    IconButton(
                      icon: Icon(Icons.playlist_add_rounded,
                          color: scheme.onSurfaceVariant),
                      onPressed: onAddToPlaylist,
                    ),
                  if (onDownload != null)
                    IconButton(
                      icon: Icon(Icons.download_rounded,
                          color: scheme.onSurfaceVariant),
                      onPressed: onDownload,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.music_note_rounded,
          color: scheme.onSurfaceVariant, size: 24),
    );
  }
}
