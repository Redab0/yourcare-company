import '../../../../data/models/profile/company_services.dart';
import '../../../../data/repositories/profile/business/business_profile_repository.dart';

class GetCompanyServicesUseCase {
  const GetCompanyServicesUseCase(this._repository);
  final BusinessProfileRepository _repository;
  Future<CompanyServices> call() => _repository.getCompanyServices();
}
