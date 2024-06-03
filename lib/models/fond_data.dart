class FondData {
  FondData({
    required this.id,
    required this.imageUrl,
    required this.fundName,
    required this.amount,
    required this.tag,
    required this.description,
    required this.contactInfo,
  });

  int id;
  String imageUrl;
  String fundName;
  double amount;
  String tag;
  String description;
  String contactInfo;

  factory FondData.fromJson(Map<String, dynamic> json) {
    return FondData(
      id: json['id'],
      imageUrl: json['imageUrl'],
      fundName: json['fundName'],
      amount: json['amount'] is String ? double.parse(json['amount']) : json['amount'].toDouble(),
      tag: json['tag'],
      description: json['description'],
      contactInfo: json['contactInfo'],
    );
  }
}