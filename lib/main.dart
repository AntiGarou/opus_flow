import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/api/deezer_api.dart';
import 'data/api/jamendo_api.dart';
import 'data/api/soundcloud_api.dart';
import 'data/api/soundcloud_client_id_provider.dart';
import 'data/api/spotify_api.dart';
import 'data/api/yandex_music_api.dart';
import 'data/preferences/playlist_storage.dart';
import 'data/repository/track_repository_impl.dart';
import 'domain/repository/track_repository.dart';
import 'presentation/bloc/home/home_cubit.dart';
import 'presentation/bloc/library/library_cubit.dart';
import 'presentation/bloc/player/player_cubit.dart';
import 'presentation/bloc/search/search_cubit.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/library/library_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/mini_player.dart';
import 'services/audio_player_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SoundFlowApp());
}

class SoundFlowApp extends StatelessWidget {
  const SoundFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final clientIdProvider = SoundCloudClientIdProvider();
    final soundCloudApi = SoundCloudApi(clientIdProvider);
    final jamendoApi = JamendoApi('');
    final deezerApi = DeezerApi();
    final yandexMusicApi = YandexMusicApi();
    final spotifyApi = SpotifyApi(
      clientId: const String.fromEnvironment('SPOTIFY_CLIENT_ID'),
      clientSecret: const String.fromEnvironment('SPOTIFY_CLIENT_SECRET'),
    );
    final trackRepository = TrackRepositoryImpl(
      soundCloudApi,
      jamendoApi,
      deezerApi,
      yandexMusicApi,
      spotifyApi,
    );
    final audioService = AudioPlayerService(
      soundCloudApi,
      yandexMusicApi: yandexMusicApi,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TrackRepository>.value(value: trackRepository),
        RepositoryProvider<YandexMusicApi>.value(value: yandexMusicApi),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => PlayerCubit(audioService)),
          BlocProvider(create: (_) => HomeCubit(trackRepository)),
          BlocProvider(create: (_) => SearchCubit(trackRepository)),
          BlocProvider(create: (_) => LibraryCubit(PlaylistStorage())),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (_, mode) => MaterialApp(
            title: 'SoundFlow',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const _RootShell(),
          ),
        ),
      ),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _tab = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music_rounded),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
