// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 0;

  @override
  Person read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person(
      firstName: fields[0] as String,
      lastName: fields[1] as String,
      mobile: fields[2] as String,
      gender: fields[3] as String,
      address: fields[4] as String,
      downloadImagePathUrl: fields[5] as String?,
      cacheImagePath: fields[7] as String?,
      downloadDocPathUrl: fields[6] as String?,
      cacheDocPath: fields[8] as String?,
      imageName: fields[9] as String?,
      docName: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.mobile)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.downloadImagePathUrl)
      ..writeByte(6)
      ..write(obj.downloadDocPathUrl)
      ..writeByte(7)
      ..write(obj.cacheImagePath)
      ..writeByte(8)
      ..write(obj.cacheDocPath)
      ..writeByte(9)
      ..write(obj.imageName)
      ..writeByte(10)
      ..write(obj.docName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
