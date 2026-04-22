import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/model/artist.dart';
import '../domain/model/track.dart';
import '../domain/model/track_source.dart';

class DownloadService {
  final Dio _dio;

  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directory> _downloadsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/downloads');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> _filePathFor(String trackId) async {
    final dir = await _downloadsDir();
    return '${dir.path}/$trackId.mp3';
  }

  Future<File?> downloadTrack(Track track) async {
    final streamUrl = track.streamUrl;
    if (streamUrl == null || streamUrl.isEmpty) return null;
    final path = await _filePathFor(track.id);
    final file = File(path);
    if (await file.exists()) {
      debugPrint('DownloadService: already downloaded ${track.id}');
      return file;
    }
    try {
      await _dio.download(
        streamUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            debugPrint(
                'DownloadService: ${track.id} ${(received / total * 100).toStringAsFixed(1)}%');
          }
        },
      );
      return file;
    } catch (e) {
      debugPrint('DownloadService.downloadTrack failed: $e');
      return null;
    }
  }

  Future<List<Track>> getDownloadedTracks() async {
    final dir = await _downloadsDir();
    if (!await dir.exists()) return [];
    final files = dir.listSync().whereType<File>().where((f) =>
        f.path.toLowerCase().endsWith('.mp3'));
    return files.map((f) {
      final name = f.uri.pathSegments.last;
      final id = name.replaceAll(RegExp(r'\.mp3$'), '');
      return Track(
        id: id,
        title: id,
        artist: const Artist(id: 'local', name: 'Local'),
        streamUrl: f.path,
        source: TrackSource.local,
        isDownloadable: true,
      );
    }).toList();
  }

  Future<bool> isDownloaded(String trackId) async {
    final path = await _filePathFor(trackId);
    return File(path).exists();
  }

  Future<void> deleteDownload(String trackId) async {
    final path = await _filePathFor(trackId);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Track?> addLocalFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final name = file.uri.pathSegments.last;
    return Track(
      id: id,
      title: name,
      artist: const Artist(id: 'local', name: 'Local'),
      streamUrl: filePath,
      source: TrackSource.local,
      isDownloadable: true,
    );
  }
}
