import 'package:flutter/material.dart';

import '../../../quote/domain/entities/quote.dart';
import '../../../quote/presentation/pages/quote_pdf_preview_page.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/repositories/company_profile_repository.dart';
import '../../settings_module.dart';
import '../widgets/settings_tile.dart';
import 'company_profile_section_form_page.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final CompanyProfileRepository _repository = getCompanyProfileRepository();
  CompanyProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final savedProfile = await _repository.loadProfile();
    final profile = savedProfile ?? CompanyProfile.defaults();

    if (!mounted) return;

    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _openSection(CompanyProfileSectionType section) async {
    final profile = _profile;
    if (profile == null) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CompanyProfileSectionFormPage(
          section: section,
          initialProfile: profile,
        ),
      ),
    );

    if (updated == true) {
      await _loadProfile();
    }
  }

  Quote _buildPreviewQuote() {
    return Quote(
      quoteNumber: 1,
      createdAt: DateTime.now(),
      customerName: 'Victor Custodio',
      customerCompany: 'AQUATECNIT',
      customerPhone: '955474660',
      items: const [
        QuoteItem(
          productName: 'Disco Difusor',
          productCategory: 'Difusores',
          unitPrice: 18.0,
          quantity: 20,
        ),
      ],
    );
  }

  String _buildPreviewFileName(CompanyProfile profile) {
    final companyName = profile.companyName.trim().isEmpty
        ? 'AQUAPARTES'
        : profile.companyName.trim().toUpperCase();
    return 'VISTA PREVIA - $companyName.pdf';
  }

  Future<void> _openPdfPreview() async {
    final profile = _profile;
    if (profile == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuotePdfPreviewPage(
          quote: _buildPreviewQuote(),
          fileName: _buildPreviewFileName(profile),
          companyProfile: profile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Datos de empresa')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withAlpha(128),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Formato PDF',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Revisa como se vera la informacion de tu empresa en el encabezado de las cotizaciones.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: _openPdfPreview,
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text('Vista previa PDF'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SettingsTile(
                    icon: Icons.apartment_outlined,
                    title: 'Informacion general',
                    subtitle: 'Edita razon social, descripcion, RUC y ciudad.',
                    onTap: () =>
                        _openSection(CompanyProfileSectionType.general),
                  ),
                  const SizedBox(height: 12),
                  SettingsTile(
                    icon: Icons.contact_mail_outlined,
                    title: 'Contacto',
                    subtitle:
                        'Edita correo, web, celulares y direccion fiscal.',
                    onTap: () =>
                        _openSection(CompanyProfileSectionType.contact),
                  ),
                  const SizedBox(height: 12),
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    title: 'Contacto comercial',
                    subtitle: 'Edita responsable comercial y puesto.',
                    onTap: () =>
                        _openSection(CompanyProfileSectionType.commercial),
                  ),
                  const SizedBox(height: 12),
                  SettingsTile(
                    icon: Icons.rule_folder_outlined,
                    title: 'Condiciones por defecto',
                    subtitle: 'Edita forma de pago, moneda, entrega y validez.',
                    onTap: () =>
                        _openSection(CompanyProfileSectionType.defaults),
                  ),
                ],
              ),
            ),
    );
  }
}
