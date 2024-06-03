class EventData {
  EventData({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.data_start,
    required this.imageUrl,
    required this.ownerFondID,
    required this.ownerFondLogoUrl, // Новое поле для URL логотипа фонда
  });

  int id;
  String name;
  String description;
  String location;
  String data_start;
  String imageUrl;
  int ownerFondID;
  String ownerFondLogoUrl; // Новое поле

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      data_start: json['data_start'],
      imageUrl: json['imageUrl'],
      ownerFondID: json['ownerFondID'],
      ownerFondLogoUrl: json['ownerFondLogoUrl'], // Новое поле
    );
  }
}