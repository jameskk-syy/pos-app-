part of 'pos_profile_bloc.dart';

@immutable
sealed class PosProfileEvent {}

class CreateProfilePos extends PosProfileEvent {
  final CompanyProfileRequest companyProfileRequest;

  CreateProfilePos({required this.companyProfileRequest});
}
