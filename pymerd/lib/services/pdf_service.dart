import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models.dart';
import '../utils.dart';

class PdfService {
  const PdfService._();

  static Future<List<int>> transactionReceipt({
    required String businessName,
    required MoneyTransaction transaction,
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              businessName,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'RECIBO COMERCIAL',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Divider(),
            _row('Fecha', formatDateTime(transaction.date)),
            _row('Concepto', transaction.description),
            if ((transaction.clientName ?? '').isNotEmpty)
              _row('Cliente', transaction.clientName!),
            _row('Método', transaction.paymentMethod),
            if (transaction.category.isNotEmpty) _row('Categoría', transaction.category),
            pw.SizedBox(height: 18),
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                formatMoney(transaction.amountCents),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Spacer(),
            pw.Divider(),
            pw.Text(
              'Documento comercial interno. No constituye por sí solo un comprobante fiscal válido.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
    return document.save();
  }

  static Future<List<int>> saleReceipt({
    required String businessName,
    required SaleRecord sale,
    required List<SaleLine> lines,
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            businessName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'RECIBO COMERCIAL · VENTA #${sale.id ?? ''}',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Divider(),
          _row('Fecha', formatDateTime(sale.date)),
          _row('Cliente', sale.clientName ?? 'Venta sin cliente'),
          _row('Método', sale.paymentMethod),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.6),
              1: pw.FlexColumnWidth(0.7),
              2: pw.FlexColumnWidth(1.1),
              3: pw.FlexColumnWidth(1.1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Detalle', bold: true),
                  _cell('Cant.', bold: true, align: pw.TextAlign.center),
                  _cell('Precio', bold: true, align: pw.TextAlign.right),
                  _cell('Total', bold: true, align: pw.TextAlign.right),
                ],
              ),
              for (final line in lines)
                pw.TableRow(
                  children: [
                    _cell(line.description),
                    _cell(
                      _quantity(line.quantity),
                      align: pw.TextAlign.center,
                    ),
                    _cell(
                      formatMoney(line.unitPriceCents),
                      align: pw.TextAlign.right,
                    ),
                    _cell(
                      formatMoney(line.totalCents),
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 12),
          _row('Subtotal', formatMoney(sale.subtotalCents)),
          if (sale.discountCents > 0)
            _row('Descuento', '-${formatMoney(sale.discountCents)}'),
          if (sale.tipCents > 0) _row('Propina', formatMoney(sale.tipCents)),
          pw.Divider(),
          _row('TOTAL', formatMoney(sale.totalCents)),
          _row('Pagado', formatMoney(sale.paidCents)),
          _row('Pendiente', formatMoney(sale.balanceCents)),
          if (sale.notes.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _row('Notas', sale.notes),
          ],
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.Text(
            'Documento comercial interno. No constituye por sí solo un comprobante fiscal válido.',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _cell(
    String value, {
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(
          value,
          textAlign: align,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );

  static String _quantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static pw.Widget _row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 78,
              child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Expanded(child: pw.Text(value)),
          ],
        ),
      );
}