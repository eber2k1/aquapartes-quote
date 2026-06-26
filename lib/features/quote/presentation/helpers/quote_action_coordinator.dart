import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../core/formatters/app_formatters.dart';
import '../../../../core/services/app_notifications.dart';
import '../../../customers/domain/repositories/customers_repository.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../../services/pdf/pdf_service.dart';
import '../models/quote_form_result.dart';

class QuoteActionCoordinator {
  QuoteActionCoordinator({
    required this.repository,
    required this.pdfService,
    required this.customersRepository,
  });

  final QuotesRepository repository;
  final PdfService pdfService;
  final CustomersRepository customersRepository;

  Future<List<Quote>> loadQuotes() async {
    final result = await repository.loadQuotes();
    var normalizedQuotes = _assignMissingQuoteNumbers(result.data);

    // Hidratar nombres de clientes si la API no los devolvió
    normalizedQuotes = await _hydrateCustomerNames(normalizedQuotes);

    if (result.fromCache) {
      AppNotifications.showInfo(
        'No se pudo cargar las cotizaciones desde la API. Se mostraran los datos locales.',
      );
    }

    if (_hasMissingQuoteNumbers(result.data) || !result.fromCache) {
      await repository.saveCachedQuotes(normalizedQuotes);
    }

    return normalizedQuotes;
  }

  Future<List<Quote>> _hydrateCustomerNames(List<Quote> quotes) async {
    if (quotes.isEmpty) return quotes;

    final needsHydration = quotes.any(
      (q) => q.customerName.isEmpty && q.customerCompany.isEmpty,
    );
    if (!needsHydration) return quotes;

    try {
      final customersResult = await customersRepository.loadCustomers();
      final customers = customersResult.data;

      return quotes.map((quote) {
        if (quote.customerName.isNotEmpty || quote.customerCompany.isNotEmpty) {
          return quote;
        }

        final customer = customers
            .where((c) => c.id == quote.customerId)
            .firstOrNull;
        if (customer != null) {
          return quote.copyWith(
            customerName: customer.contactName,
            customerCompany: customer.companyName,
            customerPhone: customer.phone,
          );
        }
        return quote;
      }).toList();
    } catch (_) {
      return quotes;
    }
  }

  Future<List<Quote>> applyResult({
    required List<Quote> currentQuotes,
    required QuoteFormResult result,
    Quote? initialQuote,
    int? index,
  }) async {
    final quotes = List<Quote>.from(currentQuotes);

    if (result.deleted) {
      if (index == null || index < 0 || index >= quotes.length) {
        return quotes;
      }

      final deletedQuote = quotes[index];
      final quoteId = deletedQuote.id?.trim() ?? '';

      try {
        if (quoteId.isNotEmpty) {
          await repository.deleteQuote(quoteId);
        }
      } catch (_) {
        AppNotifications.showInfo(
          'La API no estuvo disponible. La cotizacion se eliminara solo localmente.',
        );
      }

      quotes.removeAt(index);
      await repository.saveCachedQuotes(quotes);
      AppNotifications.showDelete(
        '${buildQuoteLabel(deletedQuote)} eliminada correctamente.',
      );
      return quotes;
    }

    final quote = result.quote;
    if (quote == null) {
      return quotes;
    }

    final draftQuote = quote.copyWith(
      id: initialQuote?.id ?? quote.id,
      quoteNumber:
          quote.quoteNumber ??
          initialQuote?.quoteNumber ??
          _nextQuoteNumber(quotes),
      createdAt: initialQuote?.createdAt ?? quote.createdAt,
      issueDate: quote.issueDate,
      status: initialQuote?.status ?? quote.status,
      currency: initialQuote?.currency ?? quote.currency,
      taxPercent: initialQuote?.taxPercent ?? quote.taxPercent,
      createdBy: initialQuote?.createdBy ?? quote.createdBy,
      pdfFileUrl: initialQuote?.pdfFileUrl ?? quote.pdfFileUrl,
      pdfFileName: initialQuote?.pdfFileName ?? quote.pdfFileName,
    );

    final shouldCreateRemotely =
        index == null || (initialQuote?.id?.trim() ?? '').isEmpty;

    Quote savedQuote;
    var wasSavedLocallyOnly = false;

    try {
      savedQuote = shouldCreateRemotely
          ? await repository.createQuote(draftQuote)
          : await repository.updateQuote(draftQuote);

      final quoteId = savedQuote.id?.trim() ?? '';
      if (quoteId.isNotEmpty) {
        try {
          final pdfBytes = await pdfService.buildQuotePdf(savedQuote);
          final uploadedQuote = await repository.uploadQuotePdf(
            quoteId: quoteId,
            bytes: pdfBytes,
            fileName: buildQuoteFileName(savedQuote),
          );
          savedQuote = _mergeUploadedPdfQuote(
            baseQuote: savedQuote,
            uploadedQuote: uploadedQuote,
          );
        } catch (error) {
          AppNotifications.showInfo(
            'La cotizacion se guardo, pero no se pudo subir el PDF al servidor: ${readErrorMessage(error)}',
          );
        }
      }
    } catch (error) {
      if (!_shouldFallbackLocally(error)) {
        rethrow;
      }

      savedQuote = draftQuote;
      wasSavedLocallyOnly = true;
    }

    savedQuote = savedQuote.copyWith(
      customerName: savedQuote.customerName.trim().isEmpty
          ? draftQuote.customerName
          : savedQuote.customerName,
      customerCompany: savedQuote.customerCompany.trim().isEmpty
          ? draftQuote.customerCompany
          : savedQuote.customerCompany,
      customerPhone: savedQuote.customerPhone.trim().isEmpty
          ? draftQuote.customerPhone
          : savedQuote.customerPhone,
    );

    if (index == null) {
      quotes.add(savedQuote);
    } else if (index >= 0 && index < quotes.length) {
      quotes[index] = savedQuote;
    }

    await repository.saveCachedQuotes(quotes);

    if (wasSavedLocallyOnly) {
      AppNotifications.showInfo(
        index == null
            ? '${buildQuoteLabel(savedQuote)} guardada localmente porque la API no estuvo disponible.'
            : '${buildQuoteLabel(savedQuote)} actualizada localmente porque la API no estuvo disponible.',
      );
    } else {
      AppNotifications.showSuccess(
        index == null
            ? '${buildQuoteLabel(savedQuote)} creada correctamente.'
            : '${buildQuoteLabel(savedQuote)} actualizada correctamente.',
      );
    }

    return quotes;
  }

  Future<Uint8List> buildQuotePdf(Quote quote) {
    return pdfService.buildQuotePdf(quote);
  }

  String buildQuoteFileName(Quote quote) {
    return '${AppFormatters.formatQuoteNumber(quote.quoteNumber, quote.createdAt)} - '
        '${_buildQuoteCustomerLabel(quote)} - '
        '${_buildQuoteProductsLabel(quote)}.pdf';
  }

  String buildQuoteLabel(Quote quote) {
    return 'Cotización ${AppFormatters.formatQuoteNumber(quote.quoteNumber, quote.createdAt)}';
  }

  String readErrorMessage(Object error) {
    final rawMessage = error.toString().trim();
    if (rawMessage.startsWith('Exception: ')) {
      return rawMessage.substring('Exception: '.length).trim();
    }

    return rawMessage.isEmpty
        ? 'No se pudo guardar la cotizacion en la API.'
        : rawMessage;
  }

  bool _shouldFallbackLocally(Object error) {
    if (error is http.ClientException) {
      return true;
    }

    final normalizedMessage = error.toString().toLowerCase();
    const offlineHints = [
      'clientexception',
      'socketexception',
      'failed host lookup',
      'connection refused',
      'connection reset',
      'connection error',
      'network is unreachable',
      'network request failed',
      'xmlhttprequest error',
      'timed out',
    ];

    return offlineHints.any(normalizedMessage.contains);
  }

  Quote _mergeUploadedPdfQuote({
    required Quote baseQuote,
    required Quote uploadedQuote,
  }) {
    return uploadedQuote.copyWith(
      quoteNumber: uploadedQuote.quoteNumber ?? baseQuote.quoteNumber,
      createdAt: uploadedQuote.createdAt,
      issueDate: uploadedQuote.issueDate,
      customerId: uploadedQuote.customerId ?? baseQuote.customerId,
      customerName: uploadedQuote.customerName.trim().isEmpty
          ? baseQuote.customerName
          : uploadedQuote.customerName,
      customerCompany: uploadedQuote.customerCompany.trim().isEmpty
          ? baseQuote.customerCompany
          : uploadedQuote.customerCompany,
      customerPhone: uploadedQuote.customerPhone.trim().isEmpty
          ? baseQuote.customerPhone
          : uploadedQuote.customerPhone,
      items: uploadedQuote.items.isEmpty
          ? baseQuote.items
          : uploadedQuote.items,
      taxPercent: uploadedQuote.taxPercent == 0
          ? baseQuote.taxPercent
          : uploadedQuote.taxPercent,
      currency: uploadedQuote.currency.trim().isEmpty
          ? baseQuote.currency
          : uploadedQuote.currency,
      status: uploadedQuote.status.trim().isEmpty
          ? baseQuote.status
          : uploadedQuote.status,
      pdfFileUrl: uploadedQuote.pdfFileUrl ?? baseQuote.pdfFileUrl,
      pdfFileName: uploadedQuote.pdfFileName ?? baseQuote.pdfFileName,
      createdBy: uploadedQuote.createdBy.trim().isEmpty
          ? baseQuote.createdBy
          : uploadedQuote.createdBy,
      updatedAt: uploadedQuote.updatedAt ?? baseQuote.updatedAt,
      deletedAt: uploadedQuote.deletedAt ?? baseQuote.deletedAt,
    );
  }

  bool _hasMissingQuoteNumbers(List<Quote> quotes) {
    return quotes.any((quote) => quote.quoteNumber == null);
  }

  List<Quote> _assignMissingQuoteNumbers(List<Quote> quotes) {
    var nextNumber = _nextQuoteNumber(quotes);

    return quotes.map((quote) {
      if (quote.quoteNumber != null) {
        return quote;
      }

      final normalizedQuote = quote.copyWith(quoteNumber: nextNumber);
      nextNumber++;
      return normalizedQuote;
    }).toList();
  }

  int _nextQuoteNumber(List<Quote> quotes) {
    return quotes
            .map((quote) => quote.quoteNumber ?? 0)
            .fold<int>(
              0,
              (currentMax, number) => number > currentMax ? number : currentMax,
            ) +
        1;
  }

  String _buildQuoteCustomerLabel(Quote quote) {
    final customerLabel = quote.customerCompany.trim().isNotEmpty
        ? quote.customerCompany
        : quote.customerName;

    return customerLabel.trim().toUpperCase();
  }

  String _buildQuoteProductsLabel(Quote quote) {
    if (quote.items.length != 1) {
      return 'VARIOS PRODUCTOS';
    }

    final productName = quote.items.first.productName.trim();
    if (productName.isEmpty) {
      return 'VARIOS PRODUCTOS';
    }

    return productName.toUpperCase();
  }
}
