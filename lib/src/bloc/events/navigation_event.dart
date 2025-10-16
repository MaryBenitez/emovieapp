part of '../blocs/navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

// Navegar a una nueva página
class NavigateToPage extends NavigationEvent {
  final String routeName;
  final Map<String, dynamic>? arguments;
  final bool clearStack;
  final bool useCustomTransition; 

  const NavigateToPage({required this.routeName, this.arguments, this.clearStack = false, this.useCustomTransition = false});

  @override
  List<Object?> get props => [routeName, clearStack, useCustomTransition];
}

// Cargar el último estado guardado (cuando se inicia la app)
class LoadSavedState extends NavigationEvent {}

// Guardar el estado de navegación actual
class SaveNavigationState extends NavigationEvent {
  final String routeName;
  const SaveNavigationState(this.routeName);
}

// Manejar el botón de retroceso
class HandleBackButtonPress extends NavigationEvent {}

class NavigateBack extends NavigationEvent {
  const NavigateBack();
}
