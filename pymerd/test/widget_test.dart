import 'package:flutter_test/flutter_test.dart';
import 'package:pymerd/models.dart';
import 'package:pymerd/utils.dart';

void main() {
  test('formatea dinero dominicano', () {
    expect(formatMoney(123456), 'RD\$1,234.56');
    expect(formatMoney(-5000), '-RD\$50.00');
  });

  test('convierte texto monetario a centavos', () {
    expect(parseMoneyToCents('1,250.75'), 125075);
    expect(parseMoneyToCents('1.250,75'), 125075);
    expect(parseMoneyToCents('1250,7'), 125070);
  });

  test('calcula el saldo pendiente de una venta', () {
    final sale = SaleRecord(
      date: DateTime(2026, 8, 6),
      subtotalCents: 250000,
      totalCents: 240000,
      paidCents: 100000,
    );
    expect(sale.balanceCents, 140000);
  });
}
