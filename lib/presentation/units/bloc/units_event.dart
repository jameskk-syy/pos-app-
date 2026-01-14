part of 'units_bloc.dart';

@immutable
sealed class UnitsEvent {}

class LoadUnits extends UnitsEvent {}

class SearchUnits extends UnitsEvent {
  final String query;

  SearchUnits(this.query);
}

class CreateUnit extends UnitsEvent {
  final String company;
  final String uomName;

  CreateUnit({required this.company, required this.uomName});
}

class UpdateUnit extends UnitsEvent {
  final String name;
  final String uomName;
  final bool mustBeWholeNumber;

  UpdateUnit({
    required this.name,
    required this.uomName,
    required this.mustBeWholeNumber,
  });
}

class DeleteUnit extends UnitsEvent {
  final String company;
  final String uomName;

  DeleteUnit({required this.company, required this.uomName});
}
