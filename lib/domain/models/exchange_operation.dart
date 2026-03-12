/// Операция обмена валюты (запись в истории).
class ExchangeOperation {
  final int id;
  final DateTime createdAt;
  final double amountFrom;
  final String currencyFrom;
  final double amountTo;
  final String currencyTo;
  final double rateUsed;

  const ExchangeOperation({
    required this.id,
    required this.createdAt,
    required this.amountFrom,
    required this.currencyFrom,
    required this.amountTo,
    required this.currencyTo,
    required this.rateUsed,
  });

  static ExchangeOperation fromMap(Map<String, Object?> map) {
    return ExchangeOperation(
      id: map['id'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      amountFrom: (map['amount_from'] as num).toDouble(),
      currencyFrom: map['currency_from'] as String,
      amountTo: (map['amount_to'] as num).toDouble(),
      currencyTo: map['currency_to'] as String,
      rateUsed: (map['rate_used'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() => {
        'created_at': createdAt.millisecondsSinceEpoch,
        'amount_from': amountFrom,
        'currency_from': currencyFrom,
        'amount_to': amountTo,
        'currency_to': currencyTo,
        'rate_used': rateUsed,
      };
}
