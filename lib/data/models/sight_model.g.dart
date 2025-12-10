// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sight_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SightModelAdapter extends TypeAdapter<SightModel> {
  @override
  final int typeId = 0;

  @override
  SightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SightModel(
      id: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      address: fields[3] as String,
      rating: fields[4] as double,
      description: fields[5] as String,
      latitude: fields[6] as double,
      longitude: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SightModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SightModel _$SightModelFromJson(Map<String, dynamic> json) => SightModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$SightModelToJson(SightModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image_url': instance.imageUrl,
      'address': instance.address,
      'rating': instance.rating,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
