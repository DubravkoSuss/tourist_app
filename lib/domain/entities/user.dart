import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;             // id
  final String email;          // email
  final String? name;          // Username
  final String? fullName;      // Real name
  final String? dateOfBirth;   // date of birth
  final String? residence;     // Place of residence
  final String? avatarPath;    // Profile picture path

  const User({
    required this.id,
    required this.email,
    this.name,
    this.fullName,
    this.dateOfBirth,
    this.residence,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [id, email];
}
