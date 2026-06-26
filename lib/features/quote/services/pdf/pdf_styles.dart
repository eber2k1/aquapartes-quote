import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const pdfPageMargin = pw.EdgeInsets.fromLTRB(48, 24, 48, 42);
const pdfDetailIndent = 24.0;
const pdfClientDetailIndent = 40.0;
const pdfClientLabelWidth = 62.0;
const pdfDetailLabelWidth = 132.0;
const pdfColonWidth = 14.0;

pw.TextStyle pdfTextStyle({
  double fontSize = 10,
  bool bold = false,
  PdfColor color = PdfColors.black,
  pw.TextDecoration? decoration,
}) {
  return pw.TextStyle(
    fontSize: fontSize,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    color: color,
    decoration: decoration,
  );
}

pw.TextStyle pdfSectionTitleStyle() {
  return pdfTextStyle(
    bold: true,
    color: PdfColors.blue900,
    decoration: pw.TextDecoration.underline,
  );
}

pw.TextStyle pdfLinkStyle() {
  return pdfTextStyle(
    color: PdfColors.blue700,
    decoration: pw.TextDecoration.underline,
  );
}
