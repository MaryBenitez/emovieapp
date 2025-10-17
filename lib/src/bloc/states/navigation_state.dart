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
  final bool useCustomTransition;

  const NavigationSuccess({required this.routeName, this.arguments, this.useCustomTransition = false});

  @override
  List<Object?> get props => [routeName, arguments, useCustomTransition];
}

class BackPressed extends NavigationState {}