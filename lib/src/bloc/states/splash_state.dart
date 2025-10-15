part of '../blocs/splash_bloc.dart';

abstract class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashAuthenticated extends SplashState {}
class SplashUnauthenticated extends SplashState {}