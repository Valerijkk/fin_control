import 'dart:convert';
import 'package:http/http.dart' as http;

/// Простой клиент для получения курса валют из ЦБ РФ (без ключа).
/// Эндпоинт: https://www.cbr-xml-daily.ru/daily_json.js
class Rates {
  final double usd;
  final double eur;
  const Rates({required this.usd, required this.eur});
}

class RatesApi {
  static const _url = 'https://www.cbr-xml-daily.ru/daily_json.js';

  static Future<Rates> fetch() async {
    final r = await http.get(Uri.parse(_url));
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}');
    }
    final json = jsonDecode(r.body) as Map<String, dynamic>;
    final val = json['Valute'] as Map<String, dynamic>;
    final usd = (val['USD']['Value'] as num).toDouble();
    final eur = (val['EUR']['Value'] as num).toDouble();
    return Rates(usd: usd, eur: eur);
  }
}
