import 'package:equatable/equatable.dart';
import '../../domain/entities/finca.dart';

// ── EVENTS ──────────────────────────────────────────────────────────────────

abstract class FincaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFincaEvent extends FincaEvent {}

class SaveFincaEvent extends FincaEvent {
  final Finca finca;
  SaveFincaEvent(this.finca);
  @override
  List<Object?> get props => [finca];
}

class UpdateFincaEvent extends FincaEvent {
  final Finca finca;
  UpdateFincaEvent(this.finca);
  @override
  List<Object?> get props => [finca];
}

class DeleteFincaEvent extends FincaEvent {
  final int id;
  DeleteFincaEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class SelectActiveFincaEvent extends FincaEvent {
  final Finca finca;
  SelectActiveFincaEvent(this.finca);
  @override
  List<Object?> get props => [finca];
}

// ── STATES ──────────────────────────────────────────────────────────────────

abstract class FincaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FincaInitial extends FincaState {}

class FincaLoading extends FincaState {}

class FincaLoaded extends FincaState {
  final List<Finca> fincas;
  final Finca finca;
  
  FincaLoaded({required this.fincas, required this.finca});
  
  @override
  List<Object?> get props => [fincas, finca];
}

class FincaSaved extends FincaState {
  final Finca finca;
  FincaSaved(this.finca);
  @override
  List<Object?> get props => [finca];
}

class FincaError extends FincaState {
  final String message;
  FincaError(this.message);
  @override
  List<Object?> get props => [message];
}
