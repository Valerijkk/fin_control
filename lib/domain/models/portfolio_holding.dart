/// Позиция в портфеле: валюта или тикер акции, количество, средняя цена входа.
class PortfolioHolding {
  final int id;
  final String currency;
  final double amount;
  final double avgRate;
  final DateTime updatedAt;

  const PortfolioHolding({
    required this.id,
    required this.currency,
    required this.amount,
    required this.avgRate,
    required this.updatedAt,
  });

  /// Создаёт объект из строки таблицы [portfolio_holdings].
  static PortfolioHolding fromMap(Map<String, Object?> map) {
    return PortfolioHolding(
      id: map['id'] as int,
      currency: map['currency'] as String,
      amount: (map['amount'] as num).toDouble(),
      avgRate: (map['avg_rate'] as num).toDouble(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Для вставки/обновления в БД.
  Map<String, Object?> toMap() => {
        'currency': currency,
        'amount': amount,
        'avg_rate': avgRate,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };
}
