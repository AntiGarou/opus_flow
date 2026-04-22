import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/model/track_source.dart';
import '../../bloc/player/player_cubit.dart';
import '../../bloc/search/search_cubit.dart';
import '../../widgets/track_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(BuildContext context, String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      context.read<SearchCubit>().search('');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<SearchCubit>().search(trimmed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onChanged: (value) => _onQueryChanged(context, value),
                onSubmitted: (value) {
                  _debounce?.cancel();
                  context.read<SearchCubit>().search(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search tracks, artists, albums',
                  prefixIcon: Icon(Icons.search,
                      color: scheme.onSurfaceVariant),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, val, __) {
                      if (val.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _debounce?.cancel();
                          _controller.clear();
                          context.read<SearchCubit>().search('');
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (ctx, _) {
                  final source = ctx.read<SearchCubit>().source;
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _SourceChip(
                        label: 'All',
                        icon: Icons.public,
                        selected: source == SearchSource.all,
                        onTap: () => ctx
                            .read<SearchCubit>()
                            .setSource(SearchSource.all),
                      ),
                      _SourceChip(
                        label: 'SoundCloud',
                        icon: Icons.cloud_outlined,
                        selected: source == SearchSource.soundcloud,
                        onTap: () => ctx
                            .read<SearchCubit>()
                            .setSource(SearchSource.soundcloud),
                      ),
                      _SourceChip(
                        label: 'Yandex Music',
                        icon: Icons.library_music_outlined,
                        selected: source == SearchSource.yandex,
                        onTap: () => ctx
                            .read<SearchCubit>()
                            .setSource(SearchSource.yandex),
                      ),
                      _SourceChip(
                        label: 'Spotify',
                        icon: Icons.graphic_eq,
                        selected: source == SearchSource.spotify,
                        onTap: () => ctx
                            .read<SearchCubit>()
                            .setSource(SearchSource.spotify),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (ctx, state) {
                  if (state is SearchInitial) {
                    return _GenreGrid(onGenreTap: (genre) {
                      _controller.text = genre;
                      ctx.read<SearchCubit>().searchByGenre(genre);
                    });
                  }
                  if (state is SearchLoading) {
                    return const _SearchShimmer();
                  }
                  if (state is SearchError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: scheme.onSurfaceVariant, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message,
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  if (state is SearchLoaded) {
                    if (state.tracks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                color: scheme.onSurfaceVariant, size: 48),
                            const SizedBox(height: 12),
                            Text('No results found',
                                style: TextStyle(
                                    color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.tracks.length,
                      itemBuilder: (_, i) {
                        final t = state.tracks[i];
                        return TrackListItem(
                          track: t,
                          onTap: () => ctx
                              .read<PlayerCubit>()
                              .playTracks(state.tracks, startIndex: i),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SourceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: FilterChip(
        selected: selected,
        onSelected: (_) => onTap(),
        avatar: Icon(icon, size: 18),
        label: Text(label),
        showCheckmark: false,
      ),
    );
  }
}

class _GenreGrid extends StatelessWidget {
  final void Function(String genre) onGenreTap;
  const _GenreGrid({required this.onGenreTap});

  static const _genres = <String>[
    'Electronic',
    'Rock',
    'Pop',
    'Hip-Hop',
    'Jazz',
    'Classical',
    'Ambient',
    'Folk',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Rich, distinct Material 3 tonal tiles.
    final tiles = <(Color, Color)>[
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      (scheme.errorContainer, scheme.onErrorContainer),
      (scheme.primary, scheme.onPrimary),
      (scheme.secondary, scheme.onSecondary),
      (scheme.tertiary, scheme.onTertiary),
      (scheme.surfaceContainerHighest, scheme.onSurface),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _genres.length,
        itemBuilder: (_, i) {
          final name = _genres[i];
          final (bg, fg) = tiles[i];
          return Material(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onGenreTap(name),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Positioned(
                      right: -4,
                      bottom: -8,
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 72,
                        color: fg.withValues(alpha: 0.25),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        name,
                        style: TextStyle(
                          color: fg,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchShimmer extends StatelessWidget {
  const _SearchShimmer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surfaceContainerHigh,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        )),
                    const SizedBox(height: 8),
                    Container(
                        height: 10,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        )),
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
