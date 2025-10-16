import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
    ),
  );

  Bloc.observer = SimpleBlocObserver();
  await EasyLocalization.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('es'),
      startLocale: Locale(WidgetsBinding.instance.platformDispatcher.locale.languageCode),
      child: MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  final NavigationBloc navigationBloc = NavigationBloc();
  final LanguageBloc languageBloc = LanguageBloc();
  
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(navigationBloc: navigationBloc, languageBloc: languageBloc);
    
    final movieService = MovieService(apiService: apiService);
    final configService = ConfigService(apiService: apiService);
    final movieBloc = MovieBloc(movieService: movieService, configService: configService);
    final filterBloc = FilterBloc(configService: configService)..add(const LoadFilterData());
    
    final splashBloc = SplashBloc(
      apiService: apiService,
      navigationBloc: navigationBloc,
      movieBloc: movieBloc,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>.value(value: navigationBloc),
        BlocProvider<LanguageBloc>.value(value: languageBloc),
        BlocProvider<MovieBloc>.value(value: movieBloc),
        BlocProvider<SplashBloc>.value(value: splashBloc),
        BlocProvider<FilterBloc>.value(value: filterBloc),
      ],
      child: const MyAppView(),
    );
  }
}

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> with WidgetsBindingObserver {

  late NavigationBloc navigationBloc;
  final apiService = ApiService(navigationBloc: NavigationBloc(), languageBloc: LanguageBloc());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    navigationBloc = context.read<NavigationBloc>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) async {
        if (state is SplashAuthenticated) {
          context.read<NavigationBloc>().add(const NavigateToPage(routeName: '/home'));
        }
      },
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
                child: AppSafeScaffold(
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'eMovie',
                    locale: languageState.locale,
                    supportedLocales: context.supportedLocales,
                    localizationsDelegates: context.localizationDelegates,
                    home: BlocListener<NavigationBloc, NavigationState>(
                      listener: (context, state) {
                        if (state is NavigationSuccess && state.useCustomTransition) {
                          // Para movie detail, usar animación personalizada
                          final MovieModel? movie = state.arguments?['movie'];
                          final String? heroTag = state.arguments?['heroTag'];
                          
                          if (movie != null && heroTag != null) {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  return MovieDetailScreen(movie: movie, heroTag: heroTag);
                                },
                                transitionDuration: const Duration(milliseconds: 600),
                                reverseTransitionDuration: const Duration(milliseconds: 400),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  var scaleAnimation = Tween<double>(
                                    begin: 0.8,
                                    end: 1.0,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ));
                                  
                                  var fadeAnimation = Tween<double>(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                                  ));

                                  return FadeTransition(
                                    opacity: fadeAnimation,
                                    child: ScaleTransition(
                                      scale: scaleAnimation,
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        }
                      },
                      child: BlocBuilder<NavigationBloc, NavigationState>(
                        builder: (context, navState) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildPage(navState)
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPage(NavigationState state) {
    if (state is NavigationInitial || state is SplashUnauthenticated) {
      return const SplashScreen();
    } else if (state is NavigationSuccess) {
      switch (state.routeName) {
        case '/home':
          return const HomeScreen();
        default:
          return const SplashScreen();
      }
    }
    return const SplashScreen();
  }
}
