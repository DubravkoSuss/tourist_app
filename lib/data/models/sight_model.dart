// ignore_for_file: overridden_fields -> I am using this to remove warnings

import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/sight.dart';

part 'sight_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class SightModel extends Sight {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String name;

  @override
  @HiveField(2)
  @JsonKey(name: 'image_url')
  final String imageUrl;

  @override
  @HiveField(3)
  final String address;

  @override
  @HiveField(4)
  final double rating;

  @override
  @HiveField(5)
  final String description;

  @override
  @HiveField(6)
  final double latitude;

  @override
  @HiveField(7)
  final double longitude;

  const SightModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.rating,
    required this.description,
    required this.latitude,
    required this.longitude,
  }) : super(
    id: id,
    name: name,
    imageUrl: imageUrl,
    address: address,
    rating: rating,
    description: description,
    latitude: latitude,
    longitude: longitude,
  );

  factory SightModel.fromJson(Map<String, dynamic> json) =>
      _$SightModelFromJson(json);

  Map<String, dynamic> toJson() => _$SightModelToJson(this);

  factory SightModel.fromEntity(Sight sight) {
    return SightModel(
      id: sight.id,
      name: sight.name,
      imageUrl: sight.imageUrl,
      address: sight.address,
      rating: sight.rating,
      description: sight.description,
      latitude: sight.latitude,
      longitude: sight.longitude,
    );
  }
}