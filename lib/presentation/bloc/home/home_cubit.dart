import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/model/track.dart';
import '../../../domain/repository/track_repository.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Track> tracks;
  const HomeLoaded(this.tracks);
  @override
  List<Object?> get props => [tracks];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

class HomeCubit extends Cubit<HomeState> {
  final TrackRepository _repository;

  HomeCubit(this._repository) : super(const HomeInitial()) {
    loadTrending();
  }

  Future<void> loadTrending() async {
    emit(const HomeLoading());
    try {
      final tracks = await _repository.getTrendingTracks();
      emit(HomeLoaded(tracks));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
