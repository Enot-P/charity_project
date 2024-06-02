class TransactionData {
  final int id;
  final double sum;
  final DateTime date;
  final int fondId;
  final int userId;

  TransactionData({
    required this.id,
    required this.sum,
    required this.date,
    required this.fondId,
    required this.userId,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['ID_transaction'],
      sum: json['sum'],
      date: DateTime.parse(json['data_transaction']),
      fondId: json['id_fond'],
      userId: json['id_user'],
    );
  }
}