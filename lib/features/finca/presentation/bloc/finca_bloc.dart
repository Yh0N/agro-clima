import 'package:flutter_bloc/flutter_bloc.dart';
import 'finca_event_state.dart';
import '../../domain/usecases/finca_usecases.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/finca.dart';

class FincaBloc extends Bloc<FincaEvent, FincaState> {
  final SaveFinca saveFinca;
  final LoadFincas loadFincas;
  final DeleteFinca deleteFinca;

  List<Finca> _fincas = [];
  Finca? _activeFinca;

  FincaBloc({required this.saveFinca, required this.loadFincas, required this.deleteFinca})
      : super(FincaInitial()) {
    on<LoadFincaEvent>(_onLoad);
    on<SaveFincaEvent>(_onSave);
    on<UpdateFincaEvent>(_onUpdate);
    on<DeleteFincaEvent>(_onDelete);
    on<SelectActiveFincaEvent>(_onSelect);
  }

  Future<void> _onLoad(LoadFincaEvent event, Emitter<FincaState> emit) async {
    emit(FincaLoading());
    final result = await loadFincas(NoParams());
    result.fold(
      (failure) => emit(FincaError(failure.message)),
      (fincasList) {
        _fincas = fincasList;
        if (_fincas.isNotEmpty) {
          _activeFinca = _fincas.first;
          emit(FincaLoaded(fincas: _fincas, finca: _activeFinca!));
        } else {
          emit(FincaError('No hay fincas'));
        }
      },
    );
  }

  Future<void> _onSave(SaveFincaEvent event, Emitter<FincaState> emit) async {
    emit(FincaLoading());
    final result = await saveFinca(event.finca);
    result.fold(
      (failure) => emit(FincaError(failure.message)),
      (savedFinca) {
        final index = _fincas.indexWhere((f) => f.id == savedFinca.id);
        if (index >= 0) {
          _fincas[index] = savedFinca;
        } else {
          _fincas.add(savedFinca);
        }
        _activeFinca = savedFinca;
        
        emit(FincaSaved(savedFinca));
        emit(FincaLoaded(fincas: _fincas, finca: _activeFinca!));
      },
    );
  }

  Future<void> _onUpdate(UpdateFincaEvent event, Emitter<FincaState> emit) async {
    add(SaveFincaEvent(event.finca));
  }

  Future<void> _onDelete(DeleteFincaEvent event, Emitter<FincaState> emit) async {
    emit(FincaLoading());
    final result = await deleteFinca(event.id);
    result.fold(
      (failure) => emit(FincaError(failure.message)),
      (_) {
        _fincas.removeWhere((f) => f.id == event.id);
        if (_activeFinca?.id == event.id) {
          _activeFinca = _fincas.isNotEmpty ? _fincas.first : null;
        }
        if (_fincas.isNotEmpty) {
          emit(FincaLoaded(fincas: _fincas, finca: _activeFinca!));
        } else {
          emit(FincaError('No hay fincas'));
        }
      },
    );
  }

  Future<void> _onSelect(SelectActiveFincaEvent event, Emitter<FincaState> emit) async {
    _activeFinca = event.finca;
    emit(FincaLoaded(fincas: _fincas, finca: _activeFinca!));
  }
}
