import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants.dart';
import '../../domain/model/playback_state.dart';
import '../bloc/player/player_cubit.dart';
import '../screens/player/full_screen_player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = const Color(AppColors.primary);
    final bg = isDark ? const Color(0xFF282828) : Colors.white;
    final fg = isDark ? Colors.white : const Color(0xFF333333);

    return BlocBuilder<PlayerCubit, PlaybackState>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) return const SizedBox.shrink();
        final progress = state.duration.inMilliseconds == 0
            ? 0.0
            : (state.position.inMilliseconds / state.duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Material(
          color: bg,
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
                    ).chain(CurveTween(curve: Curves.easeOut));
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
                  backgroundColor:
                      isDark ? Colors.white10 : Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(primary),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: track.artworkUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: track.artworkUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      Container(color: Colors.grey[800]),
                                )
                              : Container(color: Colors.grey[800]),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                                  color: fg, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              track.artist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          state.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: fg,
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
                        icon: Icon(Icons.close, color: fg, size: 20),
                        onPressed: () => context
                            .read<PlayerCubit>()
                            .stop(clearQueue: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
