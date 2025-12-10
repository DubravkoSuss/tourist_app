import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/sight.dart';
import '../../../domain/usecases/sights/get_sights_usecase.dart';

// Events
abstract class SightsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSightsEvent extends SightsEvent {}

// States
abstract class SightsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SightsInitial extends SightsState {}

class SightsLoading extends SightsState {}

class SightsLoaded extends SightsState {
  final List<Sight> sights;

  SightsLoaded(this.sights);

  @override
  List<Object?> get props => [sights];
}

class SightsEmpty extends SightsState {}

class SightsError extends SightsState {
  final String message;

  SightsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SightsBloc extends Bloc<SightsEvent, SightsState> {
  final GetSightsUseCase getSights;

  SightsBloc({required this.getSights}) : super(SightsInitial()) {
    on<LoadSightsEvent>(_onLoadSights);
  }

  Future<void> _onLoadSights(
    LoadSightsEvent event,
    Emitter<SightsState> emit,
  ) async {
    emit(SightsLoading());
    try {
      final sights = await getSights();
      if (sights.isEmpty) {
        emit(SightsEmpty());
      } else {
        emit(SightsLoaded(sights));
      }
    } catch (e) {
      emit(SightsError(e.toString()));
    }
  }
}
