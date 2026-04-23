import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/api/deezer_api.dart';
import 'data/api/jamendo_api.dart';
import 'data/api/soundcloud_api.dart';
import 'data/api/soundcloud_client_id_provider.dart';
import 'data/api/spotify_api.dart';
import 'data/api/yandex_music_api.dart';
import 'data/preferences/credentials_store.dart';
import 'data/preferences/playlist_storage.dart';
import 'data/repository/track_repository_impl.dart';
import 'domain/repository/track_repository.dart';
import 'presentation/bloc/downloads/downloads_cubit.dart';
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
import 'services/download_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final credentials = CredentialsStore();
  await credentials.load();
  runApp(SoundFlowApp(credentials: credentials));
}

class SoundFlowApp extends StatelessWidget {
  final CredentialsStore credentials;

  const SoundFlowApp({super.key, required this.credentials});

  @override
  Widget build(BuildContext context) {
    final clientIdProvider = SoundCloudClientIdProvider();
    final soundCloudApi = SoundCloudApi(clientIdProvider);
    final jamendoApi = JamendoApi(credentials: credentials);
    final deezerApi = DeezerApi();
    final yandexMusicApi = YandexMusicApi(credentials: credentials);
    final spotifyApi = SpotifyApi(credentials: credentials);
    final trackRepository = TrackRepositoryImpl(
      soundCloudApi,
      jamendoApi,
      deezerApi,
      yandexMusicApi,
      spotifyApi,
    );
    final downloadService = DownloadService(
      soundCloudApi: soundCloudApi,
      yandexMusicApi: yandexMusicApi,
    );
    final audioService = AudioPlayerService(
      soundCloudApi,
      yandexMusicApi: yandexMusicApi,
      downloadService: downloadService,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CredentialsStore>.value(value: credentials),
        RepositoryProvider<TrackRepository>.value(value: trackRepository),
        RepositoryProvider<YandexMusicApi>.value(value: yandexMusicApi),
        RepositoryProvider<DownloadService>.value(value: downloadService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => PlayerCubit(audioService)),
          BlocProvider(create: (_) => HomeCubit(trackRepository)),
          BlocProvider(create: (_) => SearchCubit(trackRepository)),
          BlocProvider(create: (_) => LibraryCubit(PlaylistStorage())),
          BlocProvider(create: (_) => DownloadsCubit(downloadService)),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (_, mode) => MaterialApp(
            title: 'OpusFlow',
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
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
