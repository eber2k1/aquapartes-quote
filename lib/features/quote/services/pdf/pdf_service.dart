import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../catalog/catalog_module.dart';
import '../../../settings/settings_module.dart';
import '../../../settings/domain/entities/company_profile.dart';
import '../../domain/entities/quote.dart';
import 'pdf_styles.dart';
import 'quote_pdf_sections.dart';

class PdfService {
  final _catalogRepository = getCatalogRepository();
  final _companyProfileRepository = getCompanyProfileRepository();

  Future<Uint8List> buildQuotePdf(
    Quote quote, {
    CompanyProfile? companyProfile,
  }) async {
    final pdf = pw.Document();
    final catalogProducts = await _catalogRepository.loadCachedProducts();
    final resolvedCompanyProfile =
        companyProfile ??
        await _companyProfileRepository.loadProfile() ??
        CompanyProfile.defaults();

    final logoBytes = await rootBundle.load('assets/aquapartes_logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final today = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pdfPageMargin,
        footer: (context) => buildPdfFooter(resolvedCompanyProfile),
        build: (context) => [
          ...buildHeaderSection(
            logoImage: logoImage,
            today: today,
            companyProfile: resolvedCompanyProfile,
          ),
          ...buildClientSection(quote),
          ...buildGreetingSection(),
          ...buildItemsSection(quote, catalogProducts),
          ...buildOfferIncludesSection(),
          ...buildConditionsSection(resolvedCompanyProfile),
          ...buildBankAccountsSection(),
          ...buildClosingSection(
            logoImage: logoImage,
            companyProfile: resolvedCompanyProfile,
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
