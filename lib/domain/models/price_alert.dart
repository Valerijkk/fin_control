/// Оповещение при достижении курса валют (как в криптобиржах).
/// Соответствует строке таблицы [price_alerts]; id — AUTOINCREMENT.
class PriceAlert {
  final int id;
  final String currencyFrom;
  final String currencyTo;
  final double targetRate;
  /// true — уведомить когда курс >= targetRate, false — когда <= targetRate.
  final bool isAbove;
  final DateTime createdAt;
  final bool notified;

  const PriceAlert({
    required this.id,
    required this.currencyFrom,
    required this.currencyTo,
    required this.targetRate,
    required this.isAbove,
    required this.createdAt,
    this.notified = false,
  });

  /// Создаёт объект из строки таблицы [price_alerts].
  static PriceAlert fromMap(Map<String, Object?> map) {
    return PriceAlert(
      id: map['id'] as int,
      currencyFrom: map['currency_from'] as String,
      currencyTo: map['currency_to'] as String,
      targetRate: (map['target_rate'] as num).toDouble(),
      isAbove: (map['is_above'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      notified: (map['notified'] as int?) == 1,
    );
  }

  /// Для вставки в БД (без [id], т.к. AUTOINCREMENT).
  Map<String, Object?> toMap() => {
        'currency_from': currencyFrom,
        'currency_to': currencyTo,
        'target_rate': targetRate,
        'is_above': isAbove ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'notified': notified ? 1 : 0,
      };
}
