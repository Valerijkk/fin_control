// test/unit/rates_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_control/services/rates_api.dart';

void main() {
  group('Rates', () {
    test('fromJson парсит кэш', () {
      final j = {
        'rates': {'USD': 0.012, 'EUR': 0.011},
        'asOf': 1700000000000,
        'source': 'cache',
      };
      final r = Rates.fromJson(j);
      expect(r.rates['USD'], 0.012);
      expect(r.rates['EUR'], 0.011);
      expect(r.fromCache, isTrue);
      expect(r.source, 'cache');
      expect(r.asOf, isNotNull);
    });

    test('toJson и fromJson круговая сериализация', () {
      const r = Rates({'USD': 0.01, 'EUR': 0.009}, asOf: null, source: 'test');
      final j = r.toJson();
      final r2 = Rates.fromJson(j);
      expect(r2.rates['USD'], r.rates['USD']);
      expect(r2.rates['EUR'], r.rates['EUR']);
      expect(r2.fromCache, isTrue);
    });

    test('usd и eur геттеры', () {
      const r = Rates({'USD': 0.02, 'EUR': 0.018});
      expect(r.usd, 0.02);
      expect(r.eur, 0.018);
    });

    test('rate() возвращает null для отсутствующего кода', () {
      const r = Rates({'USD': 0.01});
      expect(r.rate('USD'), 0.01);
      expect(r.rate('XXX'), isNull);
    });

    test('fromJson с пустым rates', () {
      final r = Rates.fromJson({'rates': {}, 'asOf': null, 'source': 'cache'});
      expect(r.rates, isEmpty);
      expect(r.usd, 0);
      expect(r.eur, 0);
    });

    test('fromJson без asOf', () {
      final r = Rates.fromJson({'rates': {'USD': 0.01}, 'source': 'test'});
      expect(r.asOf, isNull);
      expect(r.rates['USD'], 0.01);
    });
  });
}
