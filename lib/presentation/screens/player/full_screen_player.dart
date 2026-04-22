import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants.dart';
import '../../../data/api/yandex_music_api.dart';
import '../../../domain/model/playback_state.dart';
import '../../../domain/model/track.dart';
import '../../../domain/model/track_source.dart';
import '../../bloc/library/library_cubit.dart';
import '../../bloc/player/player_cubit.dart';

class FullScreenPlayer extends StatefulWidget {
  const FullScreenPlayer({super.key});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  bool _dragging = false;
  double _dragValue = 0;

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString();
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primary = Color(AppColors.primary);

    return BlocBuilder<PlayerCubit, PlaybackState>(
      builder: (ctx, state) {
        final track = state.currentTrack;
        if (track == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final total = state.duration.inMilliseconds.toDouble();
        final pos = _dragging
            ? _dragValue
            : state.position.inMilliseconds.toDouble().clamp(0, total);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF1a1a2e), Color(0xFF121212)]
                    : const [Color(0xFFe8f5e9), Color(0xFFF8F8F8)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _appBar(context, track),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _artwork(track),
                          const SizedBox(height: 32),
                          _titleRow(track, isDark),
                          const SizedBox(height: 24),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                              activeTrackColor: primary,
                              inactiveTrackColor:
                                  isDark ? Colors.white24 : Colors.black26,
                              thumbColor: primary,
                            ),
                            child: Slider(
                              min: 0,
                              max: total <= 0 ? 1 : total,
                              value: pos.toDouble().clamp(0, total <= 0 ? 1 : total),
                              onChangeStart: (v) {
                                setState(() {
                                  _dragging = true;
                                  _dragValue = v;
                                });
                              },
                              onChanged: (v) {
                                setState(() => _dragValue = v);
                              },
                              onChangeEnd: (v) {
                                setState(() => _dragging = false);
                                ctx.read<PlayerCubit>().seekTo(
                                    Duration(milliseconds: v.toInt()));
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  _formatDuration(
                                      Duration(milliseconds: pos.toInt())),
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54)),
                              Text(
                                  _formatDuration(state.duration),
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _controls(ctx, state, isDark),
                          const SizedBox(height: 24),
                          _bottomControls(ctx, state, track, isDark),
                        ],
                      ),
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

  Widget _appBar(BuildContext context, Track track) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : const Color(0xFF333333);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down, color: fg, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'PLAYING FROM',
                  style: TextStyle(
                    color: fg.withAlpha(180),
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  TrackSource.displayName(track.source),
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: fg),
            onPressed: () => _showTrackMenu(context, track),
          ),
        ],
      ),
    );
  }

  Widget _artwork(Track track) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: track.artworkUrl != null
            ? CachedNetworkImage(
                imageUrl: track.artworkUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _artPlaceholder(),
                errorWidget: (_, __, ___) => _artPlaceholder(),
              )
            : _artPlaceholder(),
      ),
    );
  }

  Widget _artPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.music_note, size: 80, color: Colors.white54),
      ),
    );
  }

  Widget _titleRow(Track track, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF333333),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${track.artist.name} • ${TrackSource.displayName(track.source)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<LibraryCubit, LibraryState>(
          builder: (ctx, state) {
            final isFav = state.favorites.any((t) => t.id == track.id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: const Color(AppColors.primary),
                size: 28,
              ),
              onPressed: () =>
                  ctx.read<LibraryCubit>().toggleFavorite(track),
            );
          },
        ),
      ],
    );
  }

  Widget _controls(BuildContext ctx, PlaybackState state, bool isDark) {
    const primary = Color(AppColors.primary);
    final fg = isDark ? Colors.white : const Color(0xFF333333);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          iconSize: 28,
          icon: Icon(
            Icons.shuffle,
            color: state.shuffleEnabled ? primary : fg,
          ),
          onPressed: () => ctx
              .read<PlayerCubit>()
              .setShuffle(!state.shuffleEnabled),
        ),
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_previous, color: fg),
          onPressed: () => ctx.read<PlayerCubit>().previous(),
        ),
        Container(
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: primary),
          child: IconButton(
            iconSize: 40,
            icon: Icon(
              state.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
            ),
            onPressed: () {
              final cubit = ctx.read<PlayerCubit>();
              if (state.isPlaying) {
                cubit.pause();
              } else {
                cubit.resume();
              }
            },
          ),
        ),
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_next, color: fg),
          onPressed: () => ctx.read<PlayerCubit>().next(),
        ),
        IconButton(
          iconSize: 28,
          icon: Icon(
            state.repeatMode == PlaybackRepeatMode.one
                ? Icons.repeat_one
                : Icons.repeat,
            color:
                state.repeatMode != PlaybackRepeatMode.off ? primary : fg,
          ),
          onPressed: () {
            final next = switch (state.repeatMode) {
              PlaybackRepeatMode.off => PlaybackRepeatMode.all,
              PlaybackRepeatMode.all => PlaybackRepeatMode.one,
              PlaybackRepeatMode.one => PlaybackRepeatMode.off,
            };
            ctx.read<PlayerCubit>().setRepeatMode(next);
          },
        ),
      ],
    );
  }

  Widget _bottomControls(
      BuildContext ctx, PlaybackState state, Track track, bool isDark) {
    const primary = Color(AppColors.primary);
    final fg = isDark ? Colors.white70 : Colors.black54;
    final lyricsAvailable = track.source == TrackSource.yandex;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          tooltip: 'Queue',
          icon: Icon(Icons.queue_music, color: fg),
          onPressed: () => _showQueueSheet(ctx, state),
        ),
        IconButton(
          tooltip: 'Lyrics',
          icon: Icon(Icons.lyrics,
              color: lyricsAvailable ? primary : fg),
          onPressed: () => _showLyricsSheet(ctx, track),
        ),
        IconButton(
          tooltip: 'Share',
          icon: Icon(Icons.share, color: fg),
          onPressed: () => _shareTrack(ctx, track),
        ),
      ],
    );
  }

  void _showLyricsSheet(BuildContext context, Track track) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: track.source != TrackSource.yandex
                ? Center(
                    child: Text(
                      'Lyrics are only available for Yandex Music tracks.\n'
                      'This track is from ${TrackSource.displayName(track.source)}.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : FutureBuilder<String?>(
                    future: _fetchLyrics(ctx, track),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final text = snapshot.data;
                      if (text == null || text.isEmpty) {
                        return const Center(
                            child: Text('Lyrics are unavailable'));
                      }
                      return SingleChildScrollView(
                        child:
                            Text(text, style: const TextStyle(fontSize: 16)),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<String?> _fetchLyrics(BuildContext context, Track track) async {
    if (track.source != TrackSource.yandex) return null;
    final api = RepositoryProvider.of<YandexMusicApi>(context);
    final id = track.id.startsWith('ym_')
        ? track.id.substring(3).split(':').first
        : track.id;
    return api.tracksLyrics(id);
  }

  void _showQueueSheet(BuildContext context, PlaybackState state) {
    final upcoming = state.queue.length > state.queueIndex + 1
        ? state.queue.sublist(state.queueIndex + 1)
        : <Track>[];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Up next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (upcoming.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('Queue is empty'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: upcoming.length,
                      itemBuilder: (_, i) {
                        final t = upcoming[i];
                        return ListTile(
                          leading: const Icon(Icons.music_note),
                          title: Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${t.artist.name} • ${TrackSource.displayName(t.source)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareTrack(BuildContext context, Track track) {
    final text =
        '${track.title} — ${track.artist.name} (${TrackSource.displayName(track.source)})';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showTrackMenu(BuildContext context, Track track) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to playlist'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showAddToPlaylistSheet(context, track);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _shareTrack(context, track);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, Track track) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (ctx) {
        return BlocBuilder<LibraryCubit, LibraryState>(
          builder: (ctx2, state) {
            if (state.playlists.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No playlists yet. Create one from the Library tab.',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: state.playlists.length,
              itemBuilder: (_, i) {
                final p = state.playlists[i];
                return ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(p.name),
                  subtitle: Text('${p.tracks.length} tracks'),
                  onTap: () {
                    ctx2
                        .read<LibraryCubit>()
                        .addTrackToPlaylist(p.id, track);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to "${p.name}"'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
