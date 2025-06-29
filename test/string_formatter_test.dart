import 'package:crypto_marketplace_simulation/src/models/mark_price.dart';
import 'package:crypto_marketplace_simulation/src/pages/home_page_state.dart';
import 'package:crypto_marketplace_simulation/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('String formatters', () {
    test('Get first three characters', () {
      const str = 'BTCUSDT';
      expect(getFirstThreeCharacters(str).toLowerCase(), 'btc');
    });

    test('Get prices string from mark prices', () {
      final markPrices = [
        MarkPrice(
          eventTime: 0,
          eventType: '',
          symbol: 'BTCUSDT',
          markPrice: '',
          estSettlePrice: '10.0',
          indexPrice: '',
          fundingRate: '',
          nextFundingTime: 0,
        ),
        MarkPrice(
          eventTime: 0,
          eventType: '',
          symbol: 'SOLUSDT',
          markPrice: '',
          estSettlePrice: '1.0',
          indexPrice: '',
          fundingRate: '',
          nextFundingTime: 0,
        ),
      ];
      final pricesString = getPricesStringFromMarkPrices(markPrices);
      expect(pricesString, 'BTCUSDT:10.0,SOLUSDT:1.0');
    });

    test('Get estimated settle price', () {
      const estSettlePrice = '10332.2370';
      final estimatedSettlePrice = getCurrentPrice(estSettlePrice);
      expect(estimatedSettlePrice, '\$10,332.24');
    });
  });
}
