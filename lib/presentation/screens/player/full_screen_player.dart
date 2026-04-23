import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/api/yandex_music_api.dart';
import '../../../domain/model/playback_state.dart';
import '../../../domain/model/track.dart';
import '../../../domain/model/track_source.dart';
import '../../bloc/downloads/downloads_cubit.dart';
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
    final scheme = Theme.of(context).colorScheme;

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
                colors: [
                  scheme.primaryContainer,
                  scheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _appBar(context, track, scheme),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _artwork(track, scheme),
                          const SizedBox(height: 32),
                          _titleRow(track, scheme),
                          const SizedBox(height: 16),
                          Slider(
                            min: 0,
                            max: total <= 0 ? 1 : total,
                            value: pos
                                .toDouble()
                                .clamp(0, total <= 0 ? 1 : total),
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    _formatDuration(Duration(
                                        milliseconds: pos.toInt())),
                                    style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontVariations: const [
                                          FontVariation('wght', 500),
                                        ])),
                                Text(
                                    _formatDuration(state.duration),
                                    style: TextStyle(
                                        color: scheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _controls(ctx, state, scheme),
                          const SizedBox(height: 24),
                          _bottomControls(ctx, state, track, scheme),
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

  Widget _appBar(BuildContext context, Track track, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'PLAYING FROM',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  TrackSource.displayName(track.source),
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => _showTrackMenu(context, track),
          ),
        ],
      ),
    );
  }

  Widget _artwork(Track track, ColorScheme scheme) {
    return AspectRatio(
      aspectRatio: 1,
      child: Hero(
        tag: 'artwork_${track.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: track.artworkUrl != null
              ? CachedNetworkImage(
                  imageUrl: track.artworkUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _artPlaceholder(scheme),
                  errorWidget: (_, __, ___) => _artPlaceholder(scheme),
                )
              : _artPlaceholder(scheme),
        ),
      ),
    );
  }

  Widget _artPlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.music_note_rounded,
            size: 96, color: scheme.onSurfaceVariant),
      ),
    );
  }

  Widget _titleRow(Track track, ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${track.artist.name} • ${TrackSource.displayName(track.source)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 15,
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
                isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: scheme.primary,
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

  Widget _controls(BuildContext ctx, PlaybackState state, ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          iconSize: 28,
          icon: Icon(
            Icons.shuffle_rounded,
            color: state.shuffleEnabled
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
          onPressed: () => ctx
              .read<PlayerCubit>()
              .setShuffle(!state.shuffleEnabled),
        ),
        IconButton(
          iconSize: 40,
          icon: Icon(Icons.skip_previous_rounded, color: scheme.onSurface),
          onPressed: () => ctx.read<PlayerCubit>().previous(),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
          onPressed: () {
            final cubit = ctx.read<PlayerCubit>();
            if (state.isPlaying) {
              cubit.pause();
            } else {
              cubit.resume();
            }
          },
          child: Icon(
            state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 42,
          ),
        ),
        IconButton(
          iconSize: 40,
          icon: Icon(Icons.skip_next_rounded, color: scheme.onSurface),
          onPressed: () => ctx.read<PlayerCubit>().next(),
        ),
        IconButton(
          iconSize: 28,
          icon: Icon(
            state.repeatMode == PlaybackRepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: state.repeatMode != PlaybackRepeatMode.off
                ? scheme.primary
                : scheme.onSurfaceVariant,
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

  Widget _bottomControls(BuildContext ctx, PlaybackState state, Track track,
      ColorScheme scheme) {
    final lyricsAvailable = track.source == TrackSource.yandex;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ChipAction(
          icon: Icons.queue_music_rounded,
          label: 'Queue',
          onTap: () => _showQueueSheet(ctx, state),
        ),
        _ChipAction(
          icon: Icons.lyrics_rounded,
          label: 'Lyrics',
          highlighted: lyricsAvailable,
          onTap: () => _showLyricsSheet(ctx, track),
        ),
        _ChipAction(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () => _shareTrack(ctx, track),
        ),
      ],
    );
  }

  void _showLyricsSheet(BuildContext context, Track track) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
                        child: Text(text,
                            style: const TextStyle(fontSize: 16, height: 1.5)),
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
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Up next',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (upcoming.isEmpty)
                  const Expanded(
                    child: Center(child: Text('Queue is empty')),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: upcoming.length,
                      itemBuilder: (_, i) {
                        final t = upcoming[i];
                        return ListTile(
                          leading: const Icon(Icons.music_note_rounded),
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

  Future<void> _shareTrack(BuildContext context, Track track) async {
    final box = context.findRenderObject() as RenderBox?;
    final subject =
        '${track.title} — ${track.artist.name}';
    final buffer = StringBuffer()
      ..writeln(track.title)
      ..writeln('by ${track.artist.name}');
    if (track.album?.title != null && track.album!.title.isNotEmpty) {
      buffer.writeln('Album: ${track.album!.title}');
    }
    buffer.writeln('Source: ${TrackSource.displayName(track.source)}');
    if (track.streamUrl != null && track.streamUrl!.startsWith('http')) {
      buffer.writeln(track.streamUrl);
    }
    await Share.share(
      buffer.toString().trim(),
      subject: subject,
      sharePositionOrigin:
          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }

  void _showTrackMenu(BuildContext context, Track track) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: BlocBuilder<DownloadsCubit, DownloadsState>(
            builder: (ctx2, dl) {
              final downloaded = dl.isDownloaded(track.id);
              final downloading = dl.isDownloading(track.id);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.playlist_add_rounded),
                    title: const Text('Add to playlist'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showAddToPlaylistSheet(context, track);
                    },
                  ),
                  ListTile(
                    leading: Icon(downloaded
                        ? Icons.download_done_rounded
                        : Icons.download_rounded),
                    title: Text(downloaded
                        ? 'Remove download'
                        : downloading
                            ? 'Cancel download'
                            : 'Download for offline'),
                    subtitle: downloading
                        ? LinearProgressIndicator(
                            value: dl.inProgress[track.id]?.fraction ?? 0,
                          )
                        : null,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      final cubit = ctx2.read<DownloadsCubit>();
                      if (downloaded) {
                        cubit.delete(track.id);
                      } else if (downloading) {
                        cubit.cancel(track.id);
                      } else {
                        cubit.download(track);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('Share'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _shareTrack(context, track);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, Track track) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
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
                  leading: const Icon(Icons.playlist_play_rounded),
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

class _ChipAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  const _ChipAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = highlighted ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
