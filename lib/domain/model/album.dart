import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final String id;
  final String title;
  final String? artworkUrl;

  const Album({
    required this.id,
    required this.title,
    this.artworkUrl,
  });

  Album copyWith({
    String? id,
    String? title,
    String? artworkUrl,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artworkUrl: artworkUrl ?? this.artworkUrl,
    );
  }

  @override
  List<Object?> get props => [id, title, artworkUrl];
}
