import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../core/formatters/app_formatters.dart';
import '../../../settings/domain/entities/company_profile.dart';
import '../../domain/entities/quote.dart';
import '../../services/pdf/pdf_service.dart';

class QuotePdfPreviewPage extends StatelessWidget {
  const QuotePdfPreviewPage({
    super.key,
    required this.quote,
    required this.fileName,
    this.companyProfile,
  });

  final Quote quote;
  final String fileName;
  final CompanyProfile? companyProfile;

  String get _previewCustomerLabel {
    final customerName = quote.customerName.trim();
    if (customerName.isNotEmpty) {
      return customerName;
    }

    final companyName = quote.customerCompany.trim();
    if (companyName.isNotEmpty) {
      return companyName;
    }

    return 'Cliente no disponible';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pdfService = PdfService();

    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa PDF')),
      body: ColoredBox(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PreviewSummaryItem(
                          label: 'Cliente',
                          value: _previewCustomerLabel,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _PreviewSummaryItem(
                          label: 'Total',
                          value: AppFormatters.formatUsd(quote.total),
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: PdfPreview(
                build: (format) => pdfService.buildQuotePdf(
                  quote,
                  companyProfile: companyProfile,
                ),
                pdfFileName: fileName,
                canDebug: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                allowPrinting: true,
                allowSharing: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSummaryItem extends StatelessWidget {
  const _PreviewSummaryItem({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
