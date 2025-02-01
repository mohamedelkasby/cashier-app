import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? userId;
  final String? picture;
  final String? name;
  final String? gender;
  final String? email;
  final String? phoneNumber;
  final int? idNumber;
  final bool? isUser;

  UserModel({
    this.email,
    this.gender,
    this.idNumber,
    this.isUser,
    this.name,
    this.phoneNumber,
    this.picture,
    this.userId,
  });

  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel(
      userId: doc.id,
      email: doc["email"] ?? '',
      name: doc["userName"] ?? '',
      gender: doc["gender"] ?? '',
      phoneNumber: doc["phoneNumber"] ?? '',
      idNumber: doc["idNumber"] ?? '',
      picture: doc["picture"] ?? '',
      isUser: doc["isUser"],
    );
  }
  factory UserModel.empty() {
    return UserModel(
      userId: '',
      email: '',
      name: '',
      gender: '',
      phoneNumber: '',
      idNumber: 0,
      picture: '',
      isUser: false,
    );
  }
}
