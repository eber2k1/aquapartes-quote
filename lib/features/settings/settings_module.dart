import 'data/datasources/company_profile_cache_datasource.dart';
import 'data/repositories/company_profile_repository_impl.dart';
import 'domain/repositories/company_profile_repository.dart';

final CompanyProfileRepository _companyProfileRepository =
    CompanyProfileRepositoryImpl(
      cacheDataSource: CompanyProfileCacheDataSource(),
    );

CompanyProfileRepository getCompanyProfileRepository() =>
    _companyProfileRepository;
