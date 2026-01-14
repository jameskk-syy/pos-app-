part of 'pos_profile_bloc.dart';

@immutable
sealed class PosProfileState {}

final class PosProfileInitial extends PosProfileState {}

final class PosProfileStateLoading extends PosProfileState {}

final class PosProfileStateSuccess extends PosProfileState {}

final class PosProfileStateFailure extends PosProfileState {
  final String error;

  PosProfileStateFailure({required this.error});
}
