import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/model/playlist.dart';
import '../../bloc/downloads/downloads_cubit.dart';
import '../../bloc/library/library_cubit.dart';
import '../../bloc/player/player_cubit.dart';
import '../../widgets/track_list_item.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (tabContext) {
            return AnimatedBuilder(
              animation: DefaultTabController.of(tabContext).animation!,
              builder: (_, __) {
                final idx = DefaultTabController.of(tabContext).index;
                if (idx != 0) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: () => _showCreatePlaylistDialog(tabContext),
                  icon: const Icon(Icons.add),
                  label: const Text('New playlist'),
                );
              },
            );
          },
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Your Library',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4),
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Playlists'),
                  Tab(text: 'Liked'),
                  Tab(text: 'Downloads'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _PlaylistsTab(),
                    _LikedTab(),
                    _DownloadsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (ctx, state) {
        if (state.playlists.isEmpty) {
          final scheme = Theme.of(context).colorScheme;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.playlist_add_rounded,
                    color: scheme.onSurfaceVariant, size: 64),
                const SizedBox(height: 12),
                Text('No playlists yet',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => _showCreatePlaylistDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create a playlist'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: state.playlists.length,
          itemBuilder: (_, i) {
            final p = state.playlists[i];
            return _PlaylistTile(playlist: p);
          },
        );
      },
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.queue_music_rounded,
            color: scheme.onPrimaryContainer),
      ),
      title: Text(playlist.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${playlist.tracks.length} tracks',
          style: TextStyle(color: scheme.onSurfaceVariant)),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showPlaylistOptions(context, playlist),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PlaylistDetailScreen(playlistId: playlist.id),
        ),
      ),
    );
  }
}

class _LikedTab extends StatelessWidget {
  const _LikedTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (ctx, state) {
        if (state.favorites.isEmpty) {
          final scheme = Theme.of(context).colorScheme;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border_rounded,
                    color: scheme.onSurfaceVariant, size: 64),
                const SizedBox(height: 12),
                Text('Songs you like will appear here',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: state.favorites.length,
          itemBuilder: (_, i) {
            final t = state.favorites[i];
            return TrackListItem(
              track: t,
              onTap: () => ctx
                  .read<PlayerCubit>()
                  .playTracks(state.favorites, startIndex: i),
            );
          },
        );
      },
    );
  }
}

class _DownloadsTab extends StatelessWidget {
  const _DownloadsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsCubit, DownloadsState>(
      builder: (ctx, state) {
        final scheme = Theme.of(context).colorScheme;
        if (state.tracks.isEmpty && state.inProgress.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_rounded,
                    color: scheme.onSurfaceVariant, size: 64),
                const SizedBox(height: 12),
                Text('No downloads yet',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(
                  'Tap the download icon on any track to save for offline.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        final inProgressEntries = state.inProgress.values.toList();
        return ListView(
          children: [
            for (final p in inProgressEntries)
              ListTile(
                leading: const Icon(Icons.downloading_rounded),
                title: Text('Downloading ${p.trackId}',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: LinearProgressIndicator(value: p.fraction),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () =>
                      ctx.read<DownloadsCubit>().cancel(p.trackId),
                ),
              ),
            for (var i = 0; i < state.tracks.length; i++)
              TrackListItem(
                track: state.tracks[i],
                onTap: () => ctx
                    .read<PlayerCubit>()
                    .playTracks(state.tracks, startIndex: i),
              ),
          ],
        );
      },
    );
  }
}

class _PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;
  const _PlaylistDetailScreen({required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (ctx, state) {
        final playlist = state.playlists
            .where((p) => p.id == playlistId)
            .cast<Playlist?>()
            .firstWhere((_) => true, orElse: () => null);
        if (playlist == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Playlist')),
            body: const Center(child: Text('Playlist not found')),
          );
        }
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: Text(playlist.name),
            actions: [
              if (playlist.tracks.isNotEmpty)
                IconButton.filled(
                  icon: const Icon(Icons.play_arrow_rounded),
                  onPressed: () => ctx
                      .read<PlayerCubit>()
                      .playTracks(playlist.tracks, startIndex: 0),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: playlist.tracks.isEmpty
              ? Center(
                  child: Text(
                    'No tracks yet. Add tracks from the search screen.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  itemCount: playlist.tracks.length,
                  itemBuilder: (_, i) {
                    final t = playlist.tracks[i];
                    return TrackListItem(
                      track: t,
                      onTap: () => ctx
                          .read<PlayerCubit>()
                          .playTracks(playlist.tracks, startIndex: i),
                    );
                  },
                ),
        );
      },
    );
  }
}

void _showCreatePlaylistDialog(BuildContext context) {
  final controller = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Playlist name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              context.read<LibraryCubit>().createPlaylist(name);
            }
            Navigator.of(ctx).pop();
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

void _showPlaylistOptions(BuildContext context, Playlist playlist) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename'),
            onTap: () {
              Navigator.of(ctx).pop();
              _showRenameDialog(context, playlist);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete playlist'),
            onTap: () {
              context.read<LibraryCubit>().deletePlaylist(playlist.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    ),
  );
}

void _showRenameDialog(BuildContext context, Playlist playlist) {
  final controller = TextEditingController(text: playlist.name);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Rename playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              context
                  .read<LibraryCubit>()
                  .renamePlaylist(playlist.id, name);
            }
            Navigator.of(ctx).pop();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
