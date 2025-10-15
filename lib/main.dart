import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {

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
  late final ApiService apiService = ApiService(navigationBloc: navigationBloc, languageBloc: languageBloc);

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>.value(value: navigationBloc),
        BlocProvider<LanguageBloc>.value(value: languageBloc),
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
                    home: BlocBuilder<NavigationBloc, NavigationState>(
                      builder: (context, navState) {
                        return _buildPage(navState);
                      },
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
          return const SplashScreen();
        default:
          return const SplashScreen();
      }
    }
    return const SplashScreen();
  }
}
