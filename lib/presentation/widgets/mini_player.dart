import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/playback_state.dart';
import '../bloc/player/player_cubit.dart';
import '../screens/player/full_screen_player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<PlayerCubit, PlaybackState>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) return const SizedBox.shrink();
        final progress = state.duration.inMilliseconds == 0
            ? 0.0
            : (state.position.inMilliseconds / state.duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Material(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => const FullScreenPlayer(),
                    transitionsBuilder: (_, animation, __, child) {
                      final tween = Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    backgroundColor: scheme.secondaryContainer,
                    valueColor:
                        AlwaysStoppedAnimation(scheme.onSecondaryContainer),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: track.artworkUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: track.artworkUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        _artPlaceholder(scheme),
                                  )
                                : _artPlaceholder(scheme),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                track.artist.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSecondaryContainer
                                      .withValues(alpha: 0.75),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: scheme.onSecondaryContainer,
                            size: 28,
                          ),
                          onPressed: () {
                            final cubit = context.read<PlayerCubit>();
                            if (state.isPlaying) {
                              cubit.pause();
                            } else {
                              cubit.resume();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: scheme.onSecondaryContainer
                                .withValues(alpha: 0.7),
                            size: 20,
                          ),
                          onPressed: () =>
                              context.read<PlayerCubit>().stop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _artPlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.music_note_rounded,
          color: scheme.onSurfaceVariant, size: 22),
    );
  }
}
