import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/model/track.dart';
import '../../bloc/home/home_cubit.dart';
import '../../bloc/library/library_cubit.dart';
import '../../bloc/player/player_cubit.dart';
import '../../widgets/track_card.dart';
import '../../widgets/track_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const _HomeShimmer();
            }
            if (state is HomeError) {
              return _HomeError(
                message: state.message,
                onRetry: () => context.read<HomeCubit>().loadTrending(),
              );
            }
            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<HomeCubit>().loadTrending(),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          _greeting(),
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Trending Now',
                        onSeeAll: () => _openAllTracks(context, state.tracks),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (ctx, i) {
                            final t = state.tracks[i];
                            return TrackCard(
                              track: t,
                              onTap: () => context
                                  .read<PlayerCubit>()
                                  .playTracks(state.tracks, startIndex: i),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemCount: state.tracks.length.clamp(0, 10),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'All Tracks',
                        onSeeAll: () => _openAllTracks(context, state.tracks),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final t = state.tracks[i];
                          return TrackListItem(
                            track: t,
                            onTap: () => context
                                .read<PlayerCubit>()
                                .playTracks(state.tracks, startIndex: i),
                            onAddToPlaylist: () =>
                                _showAddToPlaylistSheet(context, t),
                          );
                        },
                        childCount: state.tracks.length,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _openAllTracks(BuildContext context, List<Track> tracks) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _AllTracksScreen(tracks: tracks)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant, size: 48),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final hi = scheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 26, width: 180, color: Colors.white),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => Container(
                  width: 140,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < 6; i++) ...[
              Row(
                children: [
                  Container(width: 48, height: 48, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(
                            height: 10, width: 120, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _AllTracksScreen extends StatelessWidget {
  final List<Track> tracks;
  const _AllTracksScreen({required this.tracks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Tracks')),
      body: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (ctx, i) {
          final t = tracks[i];
          return TrackListItem(
            track: t,
            onTap: () => context
                .read<PlayerCubit>()
                .playTracks(tracks, startIndex: i),
            onAddToPlaylist: () => _showAddToPlaylistSheet(context, t),
          );
        },
      ),
    );
  }
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
                },
              );
            },
          );
        },
      );
    },
  );
}
