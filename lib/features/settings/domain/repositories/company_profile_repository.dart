import '../entities/company_profile.dart';

abstract class CompanyProfileRepository {
  Future<CompanyProfile?> loadProfile();
  Future<void> saveProfile(CompanyProfile profile);
}
