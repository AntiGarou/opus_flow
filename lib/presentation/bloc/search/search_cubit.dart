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
  String _lastQuery = '';
  String? _lastGenre;
  int _requestSeq = 0;

  SearchCubit(this._repository) : super(const SearchInitial());

  SearchSource get source => _source;
  String get lastQuery => _lastQuery;

  void setSource(SearchSource source) {
    if (_source == source) return;
    _source = source;
    if (_lastQuery.isNotEmpty) {
      search(_lastQuery);
    } else if (_lastGenre != null) {
      searchByGenre(_lastGenre!);
    } else {
      emit(const SearchInitial());
    }
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    _lastQuery = trimmed;
    _lastGenre = null;
    if (trimmed.isEmpty) {
      emit(const SearchInitial());
      return;
    }
    final seq = ++_requestSeq;
    emit(const SearchLoading());
    try {
      final tracks =
          await _repository.searchTracks(trimmed, source: _source);
      if (seq != _requestSeq) return;
      emit(SearchLoaded(tracks));
    } catch (e) {
      if (seq != _requestSeq) return;
      emit(SearchError(e.toString()));
    }
  }

  Future<void> searchByGenre(String genre) async {
    _lastQuery = '';
    _lastGenre = genre;
    final seq = ++_requestSeq;
    emit(const SearchLoading());
    try {
      final tracks =
          await _repository.getTracksByGenre(genre, source: _source);
      if (seq != _requestSeq) return;
      emit(SearchLoaded(tracks));
    } catch (e) {
      if (seq != _requestSeq) return;
      emit(SearchError(e.toString()));
    }
  }
}
