import '../constants/company_info.dart';

class CompanyProfile {
  const CompanyProfile({
    required this.city,
    required this.companyName,
    required this.tagline,
    required this.ruc,
    required this.email,
    required this.website,
    required this.mobile,
    required this.officePhone,
    required this.fiscalAddress,
    required this.sellerName,
    required this.sellerRole,
    required this.paymentTerms,
    required this.saleCurrency,
    required this.deliveryTime,
    required this.deliveryPlace,
    required this.quoteValidity,
  });

  final String city;
  final String companyName;
  final String tagline;
  final String ruc;
  final String email;
  final String website;
  final String mobile;
  final String officePhone;
  final String fiscalAddress;
  final String sellerName;
  final String sellerRole;
  final String paymentTerms;
  final String saleCurrency;
  final String deliveryTime;
  final String deliveryPlace;
  final String quoteValidity;

  factory CompanyProfile.defaults() {
    return const CompanyProfile(
      city: CompanyInfo.city,
      companyName: CompanyInfo.companyName,
      tagline: CompanyInfo.tagline,
      ruc: CompanyInfo.ruc,
      email: CompanyInfo.email,
      website: CompanyInfo.website,
      mobile: CompanyInfo.mobile,
      officePhone: CompanyInfo.officePhone,
      fiscalAddress: CompanyInfo.fiscalAddress,
      sellerName: CompanyInfo.sellerName,
      sellerRole: CompanyInfo.sellerRole,
      paymentTerms: CompanyInfo.paymentTerms,
      saleCurrency: CompanyInfo.saleCurrency,
      deliveryTime: CompanyInfo.deliveryTime,
      deliveryPlace: CompanyInfo.deliveryPlace,
      quoteValidity: CompanyInfo.quoteValidity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'companyName': companyName,
      'tagline': tagline,
      'ruc': ruc,
      'email': email,
      'website': website,
      'mobile': mobile,
      'officePhone': officePhone,
      'fiscalAddress': fiscalAddress,
      'sellerName': sellerName,
      'sellerRole': sellerRole,
      'paymentTerms': paymentTerms,
      'saleCurrency': saleCurrency,
      'deliveryTime': deliveryTime,
      'deliveryPlace': deliveryPlace,
      'quoteValidity': quoteValidity,
    };
  }

  CompanyProfile copyWith({
    String? city,
    String? companyName,
    String? tagline,
    String? ruc,
    String? email,
    String? website,
    String? mobile,
    String? officePhone,
    String? fiscalAddress,
    String? sellerName,
    String? sellerRole,
    String? paymentTerms,
    String? saleCurrency,
    String? deliveryTime,
    String? deliveryPlace,
    String? quoteValidity,
  }) {
    return CompanyProfile(
      city: city ?? this.city,
      companyName: companyName ?? this.companyName,
      tagline: tagline ?? this.tagline,
      ruc: ruc ?? this.ruc,
      email: email ?? this.email,
      website: website ?? this.website,
      mobile: mobile ?? this.mobile,
      officePhone: officePhone ?? this.officePhone,
      fiscalAddress: fiscalAddress ?? this.fiscalAddress,
      sellerName: sellerName ?? this.sellerName,
      sellerRole: sellerRole ?? this.sellerRole,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      saleCurrency: saleCurrency ?? this.saleCurrency,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryPlace: deliveryPlace ?? this.deliveryPlace,
      quoteValidity: quoteValidity ?? this.quoteValidity,
    );
  }

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    final defaults = CompanyProfile.defaults();
    final savedSaleCurrency = json['saleCurrency'] as String?;
    final normalizedSaleCurrency =
        savedSaleCurrency == null ||
            savedSaleCurrency.trim().isEmpty ||
            savedSaleCurrency.trim().toLowerCase() == 'soles'
        ? defaults.saleCurrency
        : savedSaleCurrency;

    return CompanyProfile(
      city: json['city'] as String? ?? defaults.city,
      companyName: json['companyName'] as String? ?? defaults.companyName,
      tagline: json['tagline'] as String? ?? defaults.tagline,
      ruc: json['ruc'] as String? ?? defaults.ruc,
      email: json['email'] as String? ?? defaults.email,
      website: json['website'] as String? ?? defaults.website,
      mobile: json['mobile'] as String? ?? defaults.mobile,
      officePhone: json['officePhone'] as String? ?? defaults.officePhone,
      fiscalAddress: json['fiscalAddress'] as String? ?? defaults.fiscalAddress,
      sellerName: json['sellerName'] as String? ?? defaults.sellerName,
      sellerRole: json['sellerRole'] as String? ?? defaults.sellerRole,
      paymentTerms: json['paymentTerms'] as String? ?? defaults.paymentTerms,
      saleCurrency: normalizedSaleCurrency,
      deliveryTime: json['deliveryTime'] as String? ?? defaults.deliveryTime,
      deliveryPlace: json['deliveryPlace'] as String? ?? defaults.deliveryPlace,
      quoteValidity: json['quoteValidity'] as String? ?? defaults.quoteValidity,
    );
  }
}
