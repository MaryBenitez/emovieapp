part of '../blocs/filter_bloc.dart';

abstract class FilterState extends Equatable {
  const FilterState();

  @override
  List<Object> get props => [];
}

class FilterInitial extends FilterState {}

class FilterLoading extends FilterState {}

class FilterLoaded extends FilterState {
  final FilterData filterData;

  const FilterLoaded({required this.filterData});

  @override
  List<Object> get props => [filterData];
}

class FilterError extends FilterState {
  final String message;

  const FilterError({required this.message});

  @override
  List<Object> get props => [message];
}