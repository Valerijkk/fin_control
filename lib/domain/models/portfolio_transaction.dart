/// Сделка купли/продажи в портфеле.
class PortfolioTransaction {
  final int id;
  final DateTime createdAt;
  final String type; // 'buy' | 'sell'
  final String currency;
  final double amount;
  final double rate;
  final double totalBase;

  const PortfolioTransaction({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.currency,
    required this.amount,
    required this.rate,
    required this.totalBase,
  });

  static PortfolioTransaction fromMap(Map<String, Object?> map) {
    return PortfolioTransaction(
      id: map['id'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      type: map['type'] as String,
      currency: map['currency'] as String,
      amount: (map['amount'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      totalBase: (map['total_base'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() => {
        'created_at': createdAt.millisecondsSinceEpoch,
        'type': type,
        'currency': currency,
        'amount': amount,
        'rate': rate,
        'total_base': totalBase,
      };
}
