import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../catalog/domain/entities/product.dart';
import '../../../settings/domain/constants/company_info.dart';
import '../../../settings/domain/entities/company_profile.dart';
import '../../domain/entities/quote.dart';
import 'pdf_helpers.dart';
import 'pdf_styles.dart';

List<pw.Widget> buildHeaderSection({
  required pw.ImageProvider logoImage,
  required DateTime today,
  required CompanyProfile companyProfile,
}) {
  return [
    pw.Center(
      child: pw.Image(
        logoImage,
        width: 210,
        height: 82,
        fit: pw.BoxFit.contain,
      ),
    ),
    pw.SizedBox(height: 24),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${companyProfile.city}, ${formatLongDate(today)}',
          style: pdfTextStyle(),
        ),
        pw.Text(
          'Cotización Nro. ${buildQuoteCode(today)}',
          style: pdfTextStyle(
            bold: true,
            color: PdfColors.red700,
            decoration: pw.TextDecoration.underline,
          ),
        ),
      ],
    ),
  ];
}

List<pw.Widget> buildClientSection(Quote quote) {
  final customerCompany = quote.customerCompany.trim();
  final customerName = quote.customerName.trim();
  final companyLabel = customerCompany.isNotEmpty
      ? customerCompany
      : (customerName.isNotEmpty ? customerName : '-');
  final attentionLabel = customerName.isNotEmpty
      ? customerName
      : (customerCompany.isNotEmpty ? customerCompany : '-');

  return [
    pw.SizedBox(height: 14),
    pw.Text('Senores:', style: pdfTextStyle()),
    pw.SizedBox(height: 3),
    pw.Text(companyLabel, style: pdfTextStyle(bold: true)),
    pw.SizedBox(height: 2),
    pw.Text(
      'Presente.-',
      style: pdfTextStyle(bold: true, decoration: pw.TextDecoration.underline),
    ),
    pw.SizedBox(height: 12),
    _detailLine('Atn.', attentionLabel),
    _detailLine('Ref.', buildReference(quote)),
    _detailLine('Telfs.', quote.customerPhone),
    _detailLine('E-mail', '-'),
  ];
}

List<pw.Widget> buildGreetingSection() {
  return [
    pw.SizedBox(height: 18),
    pw.Text('Estimados senores:', style: pdfTextStyle()),
    pw.SizedBox(height: 6),
    pw.Text(
      'Es muy grato enviarles nuestros cordiales saludos y agradeciendo su gentil invitacion, remitirles nuestra PROPUESTA TECNICO COMERCIAL por lo solicitado.',
      style: pdfTextStyle(),
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 12),
  ];
}

List<pw.Widget> buildItemsSection(Quote quote, List<Product> catalogProducts) {
  return quote.items.asMap().entries.expand((entry) {
    final item = entry.value;
    final product = findMatchingProduct(catalogProducts, item);

    return [
      _buildItemBlock(entry.key + 1, item, product),
      pw.SizedBox(height: 22),
    ];
  }).toList();
}

List<pw.Widget> buildOfferIncludesSection() {
  return [
    pw.NewPage(freeSpace: 70),
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Nuestra Oferta Incluye:'),
        pw.SizedBox(height: 6),
        for (final line in CompanyInfo.offerIncludes) _offerBullet(line),
      ],
    ),
  ];
}

List<pw.Widget> buildConditionsSection(CompanyProfile companyProfile) {
  return [
    pw.SizedBox(height: 16),
    pw.NewPage(freeSpace: 150),
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Condiciones de Venta:'),
        pw.SizedBox(height: 8),
        _specRow('Razon Social', companyProfile.companyName),
        _specRow('RUC', companyProfile.ruc),
        _specRow('Forma de Pago', companyProfile.paymentTerms),
        _specRow('Valores de Venta', companyProfile.saleCurrency),
        _specRow('Tiempo de Entrega', companyProfile.deliveryTime),
        _specRow('Lugar de Entrega', companyProfile.deliveryPlace),
        _specRow('Validez de cotizacion', companyProfile.quoteValidity),
      ],
    ),
  ];
}

List<pw.Widget> buildBankAccountsSection() {
  return [
    pw.SizedBox(height: 18),
    pw.NewPage(freeSpace: 110),
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(CompanyInfo.bankTitle),
        pw.SizedBox(height: 8),
        _specRow('Cta. Cte. SOLES', CompanyInfo.solesAccount),
        _specRow('CCI SOLES', CompanyInfo.solesCci),
        _specRow('Cta. Cte. DOLARES', CompanyInfo.dollarsAccount),
        _specRow('CCI DOLARES', CompanyInfo.dollarsCci),
      ],
    ),
  ];
}

List<pw.Widget> buildClosingSection({
  required pw.ImageProvider logoImage,
  required CompanyProfile companyProfile,
}) {
  return [
    pw.SizedBox(height: 24),
    pw.Text(
      'Sin otro particular, quedamos de ustedes a sus gratas ordenes,',
      style: pdfTextStyle(),
    ),
    pw.Text('Atentamente,', style: pdfTextStyle()),
    pw.SizedBox(height: 24),
    pw.SizedBox(
      width: 220,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            companyProfile.sellerName,
            style: pdfTextStyle(bold: true, color: PdfColors.blue900),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            companyProfile.sellerRole,
            style: pdfTextStyle(color: PdfColors.blue700),
          ),
          pw.Text(
            companyProfile.companyName,
            style: pdfTextStyle(color: PdfColors.blue700),
          ),
          pw.SizedBox(height: 6),
          _contactLink('Movil: ${companyProfile.mobile}'),
          _contactLink('Oficina: ${companyProfile.officePhone}'),
          _contactLink('e-mail: ${companyProfile.email}'),
          _contactLink('Site: ${companyProfile.website}'),
          pw.SizedBox(height: 10),
          pw.Image(logoImage, width: 112, height: 42, fit: pw.BoxFit.contain),
        ],
      ),
    ),
  ];
}

pw.Widget buildPdfFooter(CompanyProfile companyProfile) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 12),
    child: pw.Center(
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            companyProfile.fiscalAddress,
            style: pdfTextStyle(
              fontSize: 8.5,
              bold: true,
              color: PdfColors.blue900,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Oficina: ${companyProfile.officePhone} / Celular: ${companyProfile.mobile}',
            style: pdfTextStyle(
              fontSize: 8.5,
              bold: true,
              color: PdfColors.blue900,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'e-mail: ${companyProfile.email} / web: ${companyProfile.website}',
            style: pdfTextStyle(
              fontSize: 8.5,
              bold: true,
              color: PdfColors.blue900,
              decoration: pw.TextDecoration.underline,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

pw.Widget _sectionTitle(String text) {
  return pw.Text(text, style: pdfSectionTitleStyle());
}

pw.Widget _buildItemBlock(int itemNumber, QuoteItem item, Product? product) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'ITEM ${formatItemNumber(itemNumber)}',
        style: pdfSectionTitleStyle(),
      ),
      pw.SizedBox(height: 3),
      pw.Text(item.productName.toUpperCase(), style: pdfSectionTitleStyle()),
      pw.SizedBox(height: 8),
      _specRow(
        'Categoria',
        item.productCategory.isEmpty ? '-' : item.productCategory,
      ),
      _specRow('Marca', productValue(product?.brand)),
      _specRow('Procedencia', productValue(product?.origin)),
      _specRow('Modelo', productValue(product?.model)),
      if (product != null)
        ...product.attributes.map(
          (attribute) => _specRow(attribute.name, attribute.value),
        ),
      _specRow(
        'Precio Unitario',
        '${formatCurrency(item.unitPrice)} + IGV',
        bold: true,
      ),
      _specRow('Cantidad solicitada', '${item.quantity} unidades', bold: true),
      _specRow(
        'Precio Total',
        '${formatCurrency(item.subtotal)} + IGV',
        bold: true,
      ),
    ],
  );
}

pw.Widget _detailLine(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: pdfClientDetailIndent, bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 50,
          child: pw.Text(
            label,
            style: pdfTextStyle(
              bold: true,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
        pw.Text(': ', style: pdfTextStyle()),
        pw.Expanded(
          child: pw.Text(value.isEmpty ? '-' : value, style: pdfTextStyle()),
        ),
      ],
    ),
  );
}

pw.Widget _offerBullet(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: pdfDetailIndent, bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('- ', style: pdfTextStyle()),
        pw.Expanded(child: pw.Text(text, style: pdfTextStyle())),
      ],
    ),
  );
}

pw.Widget _specRow(String label, String value, {bool bold = false}) {
  final style = pdfTextStyle(bold: bold);

  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: pdfDetailIndent, bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: pdfColonWidth,
          child: pw.Text('-', style: style),
        ),
        pw.SizedBox(
          width: pdfDetailLabelWidth,
          child: pw.Text(label, style: style),
        ),
        pw.SizedBox(
          width: pdfColonWidth,
          child: pw.Text(':', style: style),
        ),
        pw.Expanded(child: pw.Text(value.isEmpty ? '-' : value, style: style)),
      ],
    ),
  );
}

pw.Widget _contactLink(String text) {
  return pw.Text(text, style: pdfLinkStyle());
}
