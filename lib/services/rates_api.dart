import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Коды валют для запроса курсов (база RUB).
const kCurrencyCodes = [
  'USD', 'EUR', 'GBP', 'CHF', 'CNY', 'JPY', 'KZT', 'TRY', 'BRL', 'INR',
];

class Rates {
  /// Курсы от RUB: 1 RUB = rates[code] в данной валюте (например 1 RUB = 0.011 USD).
  final Map<String, double> rates;
  final DateTime? asOf;
  final bool fromCache;
  final String source;

  const Rates(
    this.rates, {
    this.asOf,
    this.fromCache = false,
    this.source = 'unknown',
  });

  double get usd => rates['USD'] ?? 0;
  double get eur => rates['EUR'] ?? 0;

  double? rate(String code) => rates[code];

  Map<String, dynamic> toJson() => {
        'rates': rates,
        'asOf': asOf?.millisecondsSinceEpoch,
        'source': source,
      };

  static Rates fromJson(Map<String, dynamic> j) {
    final r = j['rates'];
    final Map<String, double> map = {};
    if (r is Map) {
      for (final e in r.entries) {
        if (e.value is num) map[e.key.toString()] = (e.value as num).toDouble();
      }
    }
    return Rates(
      map,
      asOf: j['asOf'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(j['asOf'] as int),
      fromCache: true,
      source: 'cache',
    );
  }
}

class RatesApi {
  static const _cacheKey = 'rates_cache_v2';
  static const _timeout = Duration(seconds: 5);
  static const _symbols = 'USD,EUR,GBP,CHF,CNY,JPY,KZT,TRY,BRL,INR';

  static Future<Rates> fetch() async {
    try {
      final r = await _fetchFromExchangeRateHost().timeout(_timeout);
      await _saveCache(r);
      return r;
    } catch (_) {}

    try {
      final r = await _fetchFromOpenERApi().timeout(_timeout);
      await _saveCache(r);
      return r;
    } catch (_) {}

    final cached = await _loadCache();
    if (cached != null) return cached;

    throw Exception('All providers failed and no cache available');
  }

  static Future<Rates> _fetchFromExchangeRateHost() async {
    final uri = Uri.parse(
      'https://api.exchangerate.host/latest?base=RUB&symbols=$_symbols',
    );
    final resp = await http.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'fin_control/1.0',
    });
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');

    final root = jsonDecode(resp.body);
    if (root is! Map<String, dynamic>) throw Exception('Bad JSON root');

    final ratesNode = root['rates'];
    if (ratesNode is! Map<String, dynamic>) throw Exception('Bad JSON: rates');

    final map = <String, double>{};
    for (final code in kCurrencyCodes) {
      final v = (ratesNode[code] as num?)?.toDouble();
      if (v != null) map[code] = v;
    }
    if (map.isEmpty) throw Exception('No rates');

    DateTime? asOf;
    final dateStr = root['date'] as String?;
    if (dateStr != null) asOf = DateTime.tryParse(dateStr);

    return Rates(map, asOf: asOf ?? DateTime.now(), source: 'exchangerate.host');
  }

  static Future<Rates> _fetchFromOpenERApi() async {
    final uri = Uri.parse('https://open.er-api.com/v6/latest/RUB');
    final resp = await http.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'fin_control/1.0',
    });
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');

    final root = jsonDecode(resp.body);
    if (root is! Map<String, dynamic>) throw Exception('Bad JSON root');

    if ((root['result'] as String?) != 'success') {
      throw Exception('API status is not success');
    }

    final ratesNode = root['rates'];
    if (ratesNode is! Map<String, dynamic>) throw Exception('Bad JSON rates');

    final map = <String, double>{};
    for (final code in kCurrencyCodes) {
      final v = (ratesNode[code] as num?)?.toDouble();
      if (v != null) map[code] = v;
    }
    if (map.isEmpty) throw Exception('No rates');

    DateTime? asOf;
    final ts = root['time_last_update_unix'];
    if (ts is num) asOf = DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000);

    return Rates(map, asOf: asOf ?? DateTime.now(), source: 'open.er-api.com');
  }

  static Future<void> _saveCache(Rates r) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(r.toJson()));
    } catch (_) {}
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
