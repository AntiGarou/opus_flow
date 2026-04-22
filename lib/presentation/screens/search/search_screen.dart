import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF333333)),
                textInputAction: TextInputAction.search,
                onChanged: (value) => _onQueryChanged(context, value),
                onSubmitted: (value) {
                  _debounce?.cancel();
                  context.read<SearchCubit>().search(value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      isDark ? const Color(0xFF282828) : Colors.white,
                  hintText: 'Search tracks, artists, albums...',
                  prefixIcon: const Icon(Icons.search),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (ctx, _) {
                  final source = ctx.read<SearchCubit>().source;
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _SourceChip(
                        label: 'All Sources',
                        icon: Icons.public,
                        selected: source == SearchSource.all,
                        onTap: () => ctx
                            .read<SearchCubit>()
                            .setSource(SearchSource.all),
                      ),
                      _SourceChip(
                        label: 'SoundCloud',
                        icon: Icons.cloud,
                        selected: source == SearchSource.soundcloud,
                        onTap: () => ctx
                            .read<SearchCubit>()
                            .setSource(SearchSource.soundcloud),
                      ),
                      _SourceChip(
                        label: 'Yandex Music',
                        icon: Icons.music_note,
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
                              color: Colors.grey[400], size: 48),
                          const SizedBox(height: 12),
                          Text(state.message,
                              style: TextStyle(color: Colors.grey[400])),
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
                                color: Colors.grey[400], size: 48),
                            const SizedBox(height: 12),
                            Text('No results found',
                                style:
                                    TextStyle(color: Colors.grey[400])),
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
    const primary = Color(AppColors.primary);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? primary
        : (isDark ? const Color(0xFF282828) : Colors.white);
    final fg = selected
        ? Colors.white
        : (isDark ? Colors.white70 : const Color(0xFF333333));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: selected
                ? null
                : Border.all(color: Colors.grey[700] ?? Colors.grey),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreGrid extends StatelessWidget {
  final void Function(String genre) onGenreTap;
  const _GenreGrid({required this.onGenreTap});

  static const _genres = [
    ('Electronic', 0xFF535353),
    ('Rock', 0xFF8B0000),
    ('Pop', 0xFFC0265D),
    ('Hip-Hop', 0xFFBA6B1F),
    ('Jazz', 0xFF1E3A5F),
    ('Classical', 0xFF2D4A3E),
    ('Ambient', 0xFF3D1F5C),
    ('Folk', 0xFF6B3A2A),
  ];

  @override
  Widget build(BuildContext context) {
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
          final (name, color) = _genres[i];
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onGenreTap(name),
            child: Container(
              decoration: BoxDecoration(
                color: Color(color),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
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
        ),
      ),
    );
  }
}
