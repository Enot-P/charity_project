class SubscriptionData {
  final int id;
  final int userId;
  final int fondId;

  SubscriptionData({
    required this.id,
    required this.userId,
    required this.fondId,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['ID_subscription'],
      userId: json['id_user'],
      fondId: json['id_fond'],
    );
  }
}