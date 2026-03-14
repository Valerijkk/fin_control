/// Отложенный обмен: выполнить при достижении курса (limit order в стиле биржи).
/// Соответствует строке таблицы [limit_orders]; id — AUTOINCREMENT.
class LimitOrder {
  final int id;
  final String currencyFrom;
  final String currencyTo;
  final double amountFrom;
  final double targetRate;
  /// true — исполнить когда курс >= targetRate, false — когда <=.
  final bool isAbove;
  final DateTime createdAt;
  /// pending | done | cancelled
  final String status;

  const LimitOrder({
    required this.id,
    required this.currencyFrom,
    required this.currencyTo,
    required this.amountFrom,
    required this.targetRate,
    required this.isAbove,
    required this.createdAt,
    this.status = 'pending',
  });

  /// Создаёт объект из строки таблицы [limit_orders].
  static LimitOrder fromMap(Map<String, Object?> map) {
    return LimitOrder(
      id: map['id'] as int,
      currencyFrom: map['currency_from'] as String,
      currencyTo: map['currency_to'] as String,
      amountFrom: (map['amount_from'] as num).toDouble(),
      targetRate: (map['target_rate'] as num).toDouble(),
      isAbove: (map['is_above'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      status: map['status'] as String? ?? 'pending',
    );
  }

  /// Для вставки в БД (без [id], т.к. AUTOINCREMENT).
  Map<String, Object?> toMap() => {
        'currency_from': currencyFrom,
        'currency_to': currencyTo,
        'amount_from': amountFrom,
        'target_rate': targetRate,
        'is_above': isAbove ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'status': status,
      };
}
