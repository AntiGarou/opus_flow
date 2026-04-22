import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;

  const Artist({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  Artist copyWith({
    String? id,
    String? name,
    String? avatarUrl,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, avatarUrl];
}
