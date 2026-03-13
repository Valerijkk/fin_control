// Репозиторий портфеля: баланс и базовая валюта в SharedPreferences, позиции и сделки в БД.
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/db.dart';
import '../models/portfolio_holding.dart';
import '../models/portfolio_transaction.dart';

class PortfolioRepository {
  static const _keyBalance = 'portfolio_balance';
  static const _keyBaseCurrency = 'portfolio_base_currency';
  static const _keyInitialized = 'portfolio_initialized';
  static const _defaultBalance = 100000.0;
  static const _defaultBaseCurrency = 'RUB';

  final AppDatabase _db = AppDatabase();

  /// Текущий виртуальный баланс портфеля в базовой валюте. При первом запуске инициализируется [_defaultBalance].
  Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureInitialized(prefs);
    return prefs.getDouble(_keyBalance) ?? _defaultBalance;
  }

  /// Базовая валюта (RUB) для отображения сумм.
  Future<String> getBaseCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureInitialized(prefs);
    return prefs.getString(_keyBaseCurrency) ?? _defaultBaseCurrency;
  }

  /// Устанавливает новый баланс (после покупки/продажи).
  Future<void> setBalance(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBalance, value);
  }

  Future<void> setBaseCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseCurrency, currency);
  }

  /// При первом обращении записывает дефолтный баланс и валюту в префы.
  Future<void> _ensureInitialized(SharedPreferences prefs) async {
    if (prefs.getBool(_keyInitialized) == true) return;
    await prefs.setDouble(_keyBalance, _defaultBalance);
    await prefs.setString(_keyBaseCurrency, _defaultBaseCurrency);
    await prefs.setBool(_keyInitialized, true);
  }

  /// Все позиции (валюты и акции) в портфеле.
  Future<List<PortfolioHolding>> getHoldings() async {
    final rows = await _db.getPortfolioHoldingsRaw();
    return rows.map((r) => PortfolioHolding.fromMap(r)).toList();
  }

  /// История сделок (покупки/продажи).
  Future<List<PortfolioTransaction>> getTransactions() async {
    final rows = await _db.getPortfolioTransactionsRaw();
    return rows.map((r) => PortfolioTransaction.fromMap(r)).toList();
  }

  /// Вставляет новую позицию или обновляет существующую по [currency].
  Future<void> saveOrUpdateHolding(PortfolioHolding holding) async {
    final existing = await _db.getPortfolioHoldingByCurrency(holding.currency);
    if (existing != null) {
      await _db.updatePortfolioHoldingById(existing['id'] as int, holding.toMap());
    } else {
      await _db.insertPortfolioHoldingRaw(holding.toMap());
    }
  }

  /// Добавляет сделку в историю.
  Future<void> addTransaction(PortfolioTransaction tx) async {
    await _db.insertPortfolioTransactionRaw(tx.toMap());
  }

  /// Удаляет позицию по коду валюты/тикеру.
  Future<void> deleteHolding(String currency) async {
    await _db.deletePortfolioHoldingByCurrency(currency);
  }
}
