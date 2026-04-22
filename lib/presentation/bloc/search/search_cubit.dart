import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/model/track.dart';
import '../../../domain/model/track_source.dart';
import '../../../domain/repository/track_repository.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<Track> tracks;
  const SearchLoaded(this.tracks);
  @override
  List<Object?> get props => [tracks];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}

class SearchCubit extends Cubit<SearchState> {
  final TrackRepository _repository;
  SearchSource _source = SearchSource.all;

  SearchCubit(this._repository) : super(const SearchInitial());

  SearchSource get source => _source;

  void setSource(SearchSource source) {
    _source = source;
    emit(const SearchInitial());
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }
    emit(const SearchLoading());
    try {
      final tracks =
          await _repository.searchTracks(query, source: _source);
      emit(SearchLoaded(tracks));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> searchByGenre(String genre) async {
    emit(const SearchLoading());
    try {
      final tracks = await _repository.getTracksByGenre(genre);
      emit(SearchLoaded(tracks));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
