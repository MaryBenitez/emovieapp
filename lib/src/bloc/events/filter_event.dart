part of '../blocs/filter_bloc.dart';

abstract class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object> get props => [];
}

class LoadFilterData extends FilterEvent {
  const LoadFilterData();
}

class UpdateLanguageFilter extends FilterEvent {
  final String languageCode;

  const UpdateLanguageFilter({required this.languageCode});

  @override
  List<Object> get props => [languageCode];
}

class UpdateYearFilter extends FilterEvent {
  final int year;

  const UpdateYearFilter({required this.year});

  @override
  List<Object> get props => [year];
}

class ClearFilters extends FilterEvent {
  const ClearFilters();
}

class ClearLanguageFilter extends FilterEvent {
  const ClearLanguageFilter();
}

class ClearYearFilter extends FilterEvent {
  const ClearYearFilter();
}