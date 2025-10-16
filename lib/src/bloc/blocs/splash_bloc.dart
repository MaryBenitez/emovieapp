import 'package:emovieapp/src/imports/imports.dart';

part '../events/splash_event.dart';
part '../states/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ApiService apiService;
  final NavigationBloc navigationBloc;
  final MovieBloc movieBloc;

  SplashBloc({
    required this.apiService,
    required this.navigationBloc,
    required this.movieBloc,
  }) : super(SplashInitial()) {
    on<CheckAuthentication>((event, emit) async {
      emit(SplashLoading());
      movieBloc.add(const LoadAllMovies());
      // Esperar un poco para que se complete la carga
      await Future.delayed(const Duration(seconds: 5));
      emit(SplashAuthenticated());
    });
  }
}