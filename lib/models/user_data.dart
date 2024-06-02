import 'package:flutter/material.dart';

class UserData {
  final int id;
  final String name;
  final String email;
  final roleId;
  String? secondName;
  String? cardNumber;
  String? imageUrl;
  String? password;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    this.secondName,
    this.cardNumber,
    this.imageUrl,
    this.password,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id_user'] ?? -1,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['roleName'] ?? -1,
      secondName: json['secondname'],
      cardNumber: json['card_number'],
      imageUrl: json['imageurl'],
      password: json['password'],
    );
  }
}