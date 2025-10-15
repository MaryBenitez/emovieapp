part of '../blocs/navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object?> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigationSuccess extends NavigationState {
  final String routeName;
  final Map<String, dynamic>? arguments;

  const NavigationSuccess({required this.routeName, this.arguments});

  @override
  List<Object?> get props => [routeName, arguments];
}

class BackPressed extends NavigationState {}