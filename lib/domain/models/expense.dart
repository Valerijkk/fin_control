/// Модель одной записи: расход или доход.
/// Хранится в таблице [expenses]; id — уникальный ключ, date — миллисекунды в БД.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;
  final String? imagePath;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isIncome = false,
    this.imagePath,
  });

  /// Создаёт объект из строки таблицы [expenses] (для [ExpenseRepository]).
  static Expense fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      isIncome: (map['is_income'] as int) == 1,
      imagePath: map['image_path'] as String?,
    );
  }

  /// Для вставки/обновления в БД (поля совпадают с колонками таблицы expenses).
  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.millisecondsSinceEpoch,
        'is_income': isIncome ? 1 : 0,
        'image_path': imagePath,
      };

  /// Создаёт копию с заменой указанных полей (для редактирования).
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isIncome,
    String? imagePath,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
