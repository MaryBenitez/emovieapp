part of '../blocs/splash_bloc.dart';

abstract class SplashEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthentication extends SplashEvent {
  final NavigationBloc navigationBloc;

  CheckAuthentication({required this.navigationBloc});
}