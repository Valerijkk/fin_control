import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Rates {
  final double usd;
  final double eur;
  final DateTime? asOf;
  final bool fromCache; // показаны из кэша (офлайн)
  final String source;  // имя источника (для отладки)

  const Rates(
      this.usd,
      this.eur, {
        this.asOf,
        this.fromCache = false,
        this.source = 'unknown',
      });

  Map<String, dynamic> toJson() => {
    'usd': usd,
    'eur': eur,
    'asOf': asOf?.millisecondsSinceEpoch,
    'source': source,
  };

  static Rates fromJson(Map<String, dynamic> j) {
    return Rates(
      (j['usd'] as num).toDouble(),
      (j['eur'] as num).toDouble(),
      asOf: j['asOf'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(j['asOf'] as int),
      fromCache: true,
      source: 'cache',
    );
  }
}

class RatesApi {
  static const _cacheKey = 'rates_cache_v1';
  static const _timeout = Duration(seconds: 5);

  static Future<Rates> fetch() async {
    // 1) exchangerate.host
    try {
      final r = await _fetchFromExchangeRateHost().timeout(_timeout);
      await _saveCache(r);
      return r;
    } catch (_) {
      // fallthrough
    }

    // 2) open.er-api.com
    try {
      final r = await _fetchFromOpenERApi().timeout(_timeout);
      await _saveCache(r);
      return r;
    } catch (_) {
      // fallthrough
    }

    // 3) кэш
    final cached = await _loadCache();
    if (cached != null) return cached;

    // 4) совсем печально
    throw Exception('All providers failed and no cache available');
  }

  /// ===== Providers =====

  static Future<Rates> _fetchFromExchangeRateHost() async {
    final uri = Uri.parse(
      'https://api.exchangerate.host/latest?base=RUB&symbols=USD,EUR',
    );
    final resp = await http.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'fin_control/1.0',
    });
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final root = jsonDecode(resp.body);
    if (root is! Map<String, dynamic>) throw Exception('Bad JSON root');

    final ratesNode = root['rates'];
    if (ratesNode is! Map<String, dynamic>) {
      throw Exception('Bad JSON: rates');
    }

    final usd = (ratesNode['USD'] as num?)?.toDouble();
    final eur = (ratesNode['EUR'] as num?)?.toDouble();
    if (usd == null || eur == null) throw Exception('USD/EUR missing');

    DateTime? asOf;
    final dateStr = root['date'] as String?;
    if (dateStr != null) asOf = DateTime.tryParse(dateStr);

    return Rates(usd, eur, asOf: asOf ?? DateTime.now(), source: 'exchangerate.host');
  }

  static Future<Rates> _fetchFromOpenERApi() async {
    // Документация: https://www.exchangerate-api.com/docs/free
    // Пример: https://open.er-api.com/v6/latest/RUB
    final uri = Uri.parse('https://open.er-api.com/v6/latest/RUB');
    final resp = await http.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'fin_control/1.0',
    });
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final root = jsonDecode(resp.body);
    if (root is! Map<String, dynamic>) throw Exception('Bad JSON root');

    if ((root['result'] as String?) != 'success') {
      throw Exception('API status is not success');
    }

    final ratesNode = root['rates'];
    if (ratesNode is! Map<String, dynamic>) throw Exception('Bad JSON rates');

    final usd = (ratesNode['USD'] as num?)?.toDouble();
    final eur = (ratesNode['EUR'] as num?)?.toDouble();
    if (usd == null || eur == null) throw Exception('USD/EUR missing');

    DateTime? asOf;
    final ts = root['time_last_update_unix'];
    if (ts is num) asOf = DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000);

    return Rates(usd, eur, asOf: asOf ?? DateTime.now(), source: 'open.er-api.com');
  }

  /// ===== Cache =====

  static Future<void> _saveCache(Rates r) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(r.toJson()));
    } catch (_) {
      // молча игнорируем ошибки кэша
    }
  }

  static Future<Rates?> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_cacheKey);
      if (s == null) return null;
      final j = jsonDecode(s);
      if (j is! Map<String, dynamic>) return null;
      return Rates.fromJson(j);
    } catch (_) {
      return null;
    }
  }
}
