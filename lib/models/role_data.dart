class RoleData {
  final int id;
  final String name;

  RoleData({
    required this.id,
    required this.name,
  });

  factory RoleData.fromJson(Map<String, dynamic> json) {
    return RoleData(
      id: json['ID_role'],
      name: json['name'],
    );
  }
}