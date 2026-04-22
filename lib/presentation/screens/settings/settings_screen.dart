import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../../bloc/theme/theme_cubit.dart';

enum StreamingQuality { low, normal, high }

extension _QualityX on StreamingQuality {
  String get label {
    switch (this) {
      case StreamingQuality.low:
        return 'Low (64kbps)';
      case StreamingQuality.normal:
        return 'Normal (128kbps)';
      case StreamingQuality.high:
        return 'High (320kbps)';
    }
  }

  String get key {
    switch (this) {
      case StreamingQuality.low:
        return 'low';
      case StreamingQuality.normal:
        return 'normal';
      case StreamingQuality.high:
        return 'high';
    }
  }

  static StreamingQuality fromKey(String? key) {
    switch (key) {
      case 'low':
        return StreamingQuality.low;
      case 'high':
        return StreamingQuality.high;
      default:
        return StreamingQuality.normal;
    }
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StreamingQuality _streamQuality = StreamingQuality.normal;
  StreamingQuality _downloadQuality = StreamingQuality.high;
  bool _streamOnMobileData = true;
  bool _autoplay = true;
  bool _crossfade = false;
  double _crossfadeSeconds = 4;
  bool _showLyrics = true;
  bool _equalizer = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _streamQuality = _QualityX.fromKey(p.getString('stream_quality'));
      _downloadQuality = _QualityX.fromKey(p.getString('download_quality'));
      _streamOnMobileData = p.getBool('stream_mobile') ?? true;
      _autoplay = p.getBool('autoplay') ?? true;
      _crossfade = p.getBool('crossfade') ?? false;
      _crossfadeSeconds = p.getDouble('crossfade_seconds') ?? 4;
      _showLyrics = p.getBool('show_lyrics') ?? true;
      _equalizer = p.getBool('equalizer') ?? false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('stream_quality', _streamQuality.key);
    await p.setString('download_quality', _downloadQuality.key);
    await p.setBool('stream_mobile', _streamOnMobileData);
    await p.setBool('autoplay', _autoplay);
    await p.setBool('crossfade', _crossfade);
    await p.setDouble('crossfade_seconds', _crossfadeSeconds);
    await p.setBool('show_lyrics', _showLyrics);
    await p.setBool('equalizer', _equalizer);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(AppColors.primary);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionHeader('PLAYBACK'),
          ListTile(
            leading: const Icon(Icons.high_quality, color: primary),
            title: const Text('Streaming Quality'),
            subtitle: Text(_streamQuality.label),
            onTap: () => _pickQuality(isStreaming: true),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: primary),
            title: const Text('Download Quality'),
            subtitle: Text(_downloadQuality.label),
            onTap: () => _pickQuality(isStreaming: false),
          ),
          SwitchListTile(
            secondary:
                const Icon(Icons.signal_cellular_alt, color: primary),
            title: const Text('Stream on Mobile Data'),
            value: _streamOnMobileData,
            activeColor: primary,
            onChanged: (v) {
              setState(() => _streamOnMobileData = v);
              _save();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.autorenew, color: primary),
            title: const Text('Autoplay'),
            subtitle: const Text('Play similar tracks when queue ends'),
            value: _autoplay,
            activeColor: primary,
            onChanged: (v) {
              setState(() => _autoplay = v);
              _save();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.swap_horiz, color: primary),
            title: const Text('Crossfade'),
            subtitle:
                const Text('Smooth transition between tracks'),
            value: _crossfade,
            activeColor: primary,
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
          _sectionHeader('VISUAL'),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (ctx, mode) => SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: primary),
              title: const Text('Dark Mode'),
              value: mode == ThemeMode.dark,
              activeColor: primary,
              onChanged: (_) =>
                  ctx.read<ThemeCubit>().toggleTheme(),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lyrics, color: primary),
            title: const Text('Show Lyrics'),
            value: _showLyrics,
            activeColor: primary,
            onChanged: (v) {
              setState(() => _showLyrics = v);
              _save();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.equalizer, color: primary),
            title: const Text('Equalizer'),
            value: _equalizer,
            activeColor: primary,
            onChanged: (v) {
              setState(() => _equalizer = v);
              _save();
            },
          ),
          _sectionHeader('ABOUT'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: primary),
            title: Text('Version'),
            subtitle: Text('SoundFlow v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined, color: primary),
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

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _pickQuality({required bool isStreaming}) {
    final current = isStreaming ? _streamQuality : _downloadQuality;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: StreamingQuality.values.map((q) {
            return RadioListTile<StreamingQuality>(
              title: Text(q.label),
              value: q,
              groupValue: current,
              onChanged: (v) {
                setState(() {
                  if (isStreaming) {
                    _streamQuality = v!;
                  } else {
                    _downloadQuality = v!;
                  }
                });
                _save();
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
