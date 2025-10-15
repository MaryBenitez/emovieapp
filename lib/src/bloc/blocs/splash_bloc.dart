import 'package:emovieapp/src/imports/imports.dart';

part '../events/splash_event.dart';
part '../states/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ApiService apiService;
  final NavigationBloc navigationBloc;

  SplashBloc({
    required this.apiService,
    required this.navigationBloc,
  }) : super(SplashInitial()) {
    on<CheckAuthentication>((event, emit) async {
      emit(SplashLoading());
      await Future.delayed(const Duration(seconds: 5));
      emit(SplashAuthenticated());
    });
  }
}