class UserData {
  final int id;
  final String name;
  final String email;
  final int roleId;
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
      id: json['ID_user'],
      name: json['name'],
      email: json['email'],
      roleId: json['ID_role'],
      secondName: json['secondname'],
      cardNumber: json['card_number'],
      imageUrl: json['imageUrl'],
      password: json['password'],
    );
  }
}