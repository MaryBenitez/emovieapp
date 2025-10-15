import 'package:emovieapp/src/imports/imports.dart';

part '../events/navigation_event.dart';
part '../states/navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  // Lista para almacenar el historial de navegación
  final List<String> navigationHistory = [];

  NavigationBloc() : super(NavigationInitial()) {
    // Navegar a una nueva página
    on<NavigateToPage>((event, emit) {
      if (!event.clearStack && navigationHistory.isNotEmpty && navigationHistory.last == event.routeName) {
        return;
      }
      if (event.clearStack) {
        navigationHistory.clear();
      }
      navigationHistory.add(event.routeName);
      emit(NavigationSuccess(routeName: event.routeName, arguments: event.arguments));
    });

    // Manejar el evento de retroceso
    on<HandleBackButtonPress>((event, emit) {
      if (navigationHistory.length > 1) {
        navigationHistory.removeLast(); // Eliminar la última ruta del historial
        final previousRoute = navigationHistory.last; // Obtener la ruta anterior
        emit(NavigationSuccess(routeName: previousRoute));
      } else {
        // Si no hay más historial, volvemos a la pantalla de inicio o cerramos la app
        emit(const NavigationSuccess(routeName: '/login'));  // O usar SystemNavigator.pop()
      }
    });
  }
}
