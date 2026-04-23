import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants.dart';
import '../../../data/preferences/credentials_store.dart';
import '../../bloc/theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoplay = true;
  bool _crossfade = false;
  double _crossfadeSeconds = 4;
  bool _showLyrics = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _autoplay = p.getBool('autoplay') ?? true;
      _crossfade = p.getBool('crossfade') ?? false;
      _crossfadeSeconds = p.getDouble('crossfade_seconds') ?? 4;
      _showLyrics = p.getBool('show_lyrics') ?? true;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('autoplay', _autoplay);
    await p.setBool('crossfade', _crossfade);
    await p.setDouble('crossfade_seconds', _crossfadeSeconds);
    await p.setBool('show_lyrics', _showLyrics);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final credentials = RepositoryProvider.of<CredentialsStore>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionHeader('Built-in sources', scheme),
          ListTile(
            leading: Icon(Icons.check_circle_rounded, color: scheme.primary),
            title: const Text('SoundCloud • YouTube Music • Deezer'),
            subtitle: const Text(
              'Always on — no keys or login required. Full-length audio from '
              'SoundCloud & YouTube Music. Spotify and Deezer tracks play '
              'full-length via a YouTube match instead of a 30 s preview.',
            ),
          ),
          _sectionHeader('Optional sources', scheme),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Leave these blank to stick with built-in sources. Add credentials '
              'only if you already have them.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ),
          _SpotifyTile(store: credentials),
          _YandexTile(store: credentials),
          _JamendoTile(store: credentials),
          _sectionHeader('Playback', scheme),
          ListTile(
            leading: Icon(Icons.high_quality_rounded, color: primary),
            title: const Text('Streaming & download quality'),
            subtitle: const Text('Always highest available — no limits'),
          ),
          SwitchListTile(
            secondary: Icon(Icons.autorenew_rounded, color: primary),
            title: const Text('Autoplay'),
            subtitle: const Text('Play similar tracks when queue ends'),
            value: _autoplay,
            onChanged: (v) {
              setState(() => _autoplay = v);
              _save();
            },
          ),
          SwitchListTile(
            secondary: Icon(Icons.swap_horiz_rounded, color: primary),
            title: const Text('Crossfade'),
            subtitle: const Text('Smooth transition between tracks'),
            value: _crossfade,
            onChanged: (v) {
              setState(() => _crossfade = v);
              _save();
            },
          ),
          if (_crossfade)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 12,
                      divisions: 11,
                      value: _crossfadeSeconds,
                      label: '${_crossfadeSeconds.round()}s',
                      onChanged: (v) {
                        setState(() => _crossfadeSeconds = v);
                      },
                      onChangeEnd: (_) => _save(),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('${_crossfadeSeconds.round()}s',
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          _sectionHeader('Appearance', scheme),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (ctx, mode) => SwitchListTile(
              secondary: Icon(Icons.dark_mode_rounded, color: primary),
              title: const Text('Dark Mode'),
              value: mode == ThemeMode.dark,
              onChanged: (_) => ctx.read<ThemeCubit>().toggleTheme(),
            ),
          ),
          SwitchListTile(
            secondary: Icon(Icons.lyrics_rounded, color: primary),
            title: const Text('Show Lyrics'),
            value: _showLyrics,
            onChanged: (v) {
              setState(() => _showLyrics = v);
              _save();
            },
          ),
          _sectionHeader('About', scheme),
          ListTile(
            leading: Icon(Icons.info_outline_rounded, color: primary),
            title: const Text('Version'),
            subtitle: Text(
                '${AppStrings.appName} v${AppStrings.appVersion}'),
          ),
          ListTile(
            leading: Icon(Icons.article_outlined, color: primary),
            title: const Text('Open Source Licenses'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: AppStrings.appName,
              applicationVersion: AppStrings.appVersion,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _SpotifyTile extends StatelessWidget {
  final CredentialsStore store;
  const _SpotifyTile({required this.store});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<CredentialsSnapshot>(
      stream: store.stream,
      initialData: store.snapshot,
      builder: (ctx, snap) {
        final s = snap.data ?? store.snapshot;
        return ListTile(
          leading: Icon(Icons.graphic_eq_rounded, color: scheme.primary),
          title: const Text('Spotify'),
          subtitle: Text(s.hasSpotify
              ? 'Connected (client ID …${_tail(s.spotifyClientId)})'
              : 'Not connected — tap to add client ID & secret'),
          trailing: s.hasSpotify
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => store.clearSpotify(),
                )
              : const Icon(Icons.chevron_right_rounded),
          onTap: () => _showSpotifyDialog(context),
        );
      },
    );
  }

  String _tail(String s) =>
      s.length > 4 ? s.substring(s.length - 4) : s;

  Future<void> _showSpotifyDialog(BuildContext context) async {
    final idCtrl = TextEditingController(text: store.snapshot.spotifyClientId);
    final secretCtrl =
        TextEditingController(text: store.snapshot.spotifyClientSecret);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connect Spotify'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create an app at developer.spotify.com, then paste its '
              'Client ID and Client Secret. No user login needed — we use '
              'the Client Credentials flow for search and metadata.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: 'Client ID'),
            ),
            TextField(
              controller: secretCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Client Secret'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open Spotify Developer Dashboard'),
                onPressed: () => launchUrl(
                  Uri.parse('https://developer.spotify.com/dashboard'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await store.setSpotify(
                clientId: idCtrl.text.trim(),
                secret: secretCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _YandexTile extends StatelessWidget {
  final CredentialsStore store;
  const _YandexTile({required this.store});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<CredentialsSnapshot>(
      stream: store.stream,
      initialData: store.snapshot,
      builder: (ctx, snap) {
        final s = snap.data ?? store.snapshot;
        return ListTile(
          leading: Icon(Icons.library_music_rounded, color: scheme.primary),
          title: const Text('Yandex Music'),
          subtitle: Text(s.hasYandex
              ? 'Connected (OAuth token set)'
              : 'Not connected — tap to paste OAuth token'),
          trailing: s.hasYandex
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => store.clearYandex(),
                )
              : const Icon(Icons.chevron_right_rounded),
          onTap: () => _showDialog(context),
        );
      },
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    final tokenCtrl =
        TextEditingController(text: store.snapshot.yandexOAuthToken);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connect Yandex Music'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Yandex Music requires an OAuth token to stream tracks and '
              'fetch lyrics. Get one from oauth.yandex.ru using client_id '
              '23cabbbdc6cd418abb4b39c32c41195d (Yandex Music Android).',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'OAuth Token'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open Yandex OAuth page'),
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://oauth.yandex.ru/authorize?response_type=token'
                    '&client_id=23cabbbdc6cd418abb4b39c32c41195d',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await store.setYandexOAuthToken(tokenCtrl.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _JamendoTile extends StatelessWidget {
  final CredentialsStore store;
  const _JamendoTile({required this.store});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<CredentialsSnapshot>(
      stream: store.stream,
      initialData: store.snapshot,
      builder: (ctx, snap) {
        final s = snap.data ?? store.snapshot;
        return ListTile(
          leading: Icon(Icons.cloud_queue_rounded, color: scheme.primary),
          title: const Text('Jamendo'),
          subtitle: Text(s.hasJamendo
              ? 'Connected (client ID …${_tail(s.jamendoClientId)})'
              : 'Not connected — tap to add free client ID'),
          trailing: s.hasJamendo
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => store.clearJamendo(),
                )
              : const Icon(Icons.chevron_right_rounded),
          onTap: () => _showDialog(context),
        );
      },
    );
  }

  String _tail(String s) =>
      s.length > 4 ? s.substring(s.length - 4) : s;

  Future<void> _showDialog(BuildContext context) async {
    final idCtrl = TextEditingController(text: store.snapshot.jamendoClientId);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connect Jamendo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Jamendo is free. Register an app at developer.jamendo.com '
              'and paste the generated client ID here.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: 'Client ID'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open Jamendo Developer Portal'),
                onPressed: () => launchUrl(
                  Uri.parse('https://developer.jamendo.com/v3.0'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await store.setJamendoClientId(idCtrl.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
