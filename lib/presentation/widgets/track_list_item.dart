import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants.dart';
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
    final primary = const Color(AppColors.primary);
    return BlocBuilder<PlayerCubit, PlaybackState>(
      builder: (context, player) {
        final isCurrent = player.currentTrack?.id == track.id;
        return BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, library) {
            final isFav =
                library.favorites.any((t) => t.id == track.id);
            return ListTile(
              onTap: onTap,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 48,
                  height: 48,
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
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent
                            ? primary
                            : Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Icon(Icons.equalizer, color: primary, size: 16)
                  else
                    Text(
                      _formatDuration(track.duration),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                '${track.artist.name} • ${TrackSource.displayName(track.source)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[500]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? primary : Colors.grey[500],
                    ),
                    onPressed: () =>
                        context.read<LibraryCubit>().toggleFavorite(track),
                  ),
                  if (onAddToPlaylist != null)
                    IconButton(
                      icon: Icon(Icons.playlist_add,
                          color: Colors.grey[500]),
                      onPressed: onAddToPlaylist,
                    ),
                  if (onDownload != null)
                    IconButton(
                      icon: Icon(Icons.download_outlined,
                          color: Colors.grey[500]),
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

  Widget _placeholder() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.music_note, color: Colors.white54, size: 24),
    );
  }
}
