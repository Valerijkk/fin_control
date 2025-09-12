import 'dart:convert';
import 'package:http/http.dart' as http;

class Rates {
  final double usd;
  final double eur;
  const Rates(this.usd, this.eur);
}

class RatesApi {
  static Future<Rates> fetch() async {
    final uri = Uri.parse(
      'https://api.exchangerate.host/latest?base=RUB&symbols=USD,EUR',
    );
    final r = await http.get(uri);
    if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
    final json = jsonDecode(r.body) as Map<String, dynamic>;
    final rates = (json['rates'] as Map<String, dynamic>);
    final usd = (rates['USD'] as num).toDouble();
    final eur = (rates['EUR'] as num).toDouble();
    // переводим "сколько RUB за 1 USD/EUR" → "сколько USD/EUR за 100 RUB"
    // но проще отображать как есть — оставим как есть (RUB→USD/EUR).
    return Rates(usd, eur);
  }
}
