import 'package:equatable/equatable.dart';

class Sight extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  final double rating;
  final String description;
  final double latitude;
  final double longitude;

  const Sight({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props =>
      [id, name, imageUrl, address, rating, description, latitude, longitude];
}
