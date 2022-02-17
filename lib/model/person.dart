
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

part 'person.g.dart';

@HiveType(typeId: 0)
class Person extends HiveObject{
  @HiveField(0)
  late String firstName;

  @HiveField(1)
  late String lastName;

  @HiveField(2)
  late String mobile;

  @HiveField(3)
  late String gender;

  @HiveField(4)
  late String address;

  @HiveField(5)
  late String? downloadImagePathUrl;

  @HiveField(6)
  late String? downloadDocPathUrl;

  @HiveField(7)
  late String? cacheImagePath;

  @HiveField(8)
  late String? cacheDocPath;

  @HiveField(9)
  late String? imageName;

  @HiveField(10)
  late String? docName;





  //@HiveField(6)

  Person({required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.gender,
    required this.address,
    this.downloadImagePathUrl,
    this.cacheImagePath,
    this.downloadDocPathUrl,
    this.cacheDocPath,
    this.imageName,
    this.docName}){

  }
}