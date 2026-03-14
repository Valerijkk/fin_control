/// Цель накопления (как в инвестиционных приложениях).
/// Соответствует строке таблицы [savings_goals]; id — AUTOINCREMENT.
class SavingsGoal {
  final int id;
  final String title;
  final double targetAmount;
  final String baseCurrency;
  final double currentAmount;
  final DateTime? deadline;
  final DateTime createdAt;

  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.baseCurrency,
    this.currentAmount = 0,
    this.deadline,
    required this.createdAt,
  });

  /// Доля накопления от цели в процентах (0..100); при targetAmount <= 0 возвращает 0.
  double get progressPercent =>
      targetAmount <= 0 ? 0 :       (currentAmount / targetAmount * 100).clamp(0, 100);

  /// Создаёт объект из строки таблицы [savings_goals].
  static SavingsGoal fromMap(Map<String, Object?> map) {
    final deadlineMs = map['deadline'] as int?;
    return SavingsGoal(
      id: map['id'] as int,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      baseCurrency: map['base_currency'] as String,
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0,
      deadline: deadlineMs != null ? DateTime.fromMillisecondsSinceEpoch(deadlineMs) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Для вставки/обновления в БД (без [id], т.к. при вставке id генерируется).
  Map<String, Object?> toMap() => {
        'title': title,
        'target_amount': targetAmount,
        'base_currency': baseCurrency,
        'current_amount': currentAmount,
        'deadline': deadline?.millisecondsSinceEpoch,
        'created_at': createdAt.millisecondsSinceEpoch,
      };
}
