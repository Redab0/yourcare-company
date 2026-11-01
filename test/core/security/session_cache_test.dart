import 'dart:async';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_business_profile_usecase.dart';
import 'package:cleaning_service_driver/features/screens/home/company_profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'a preload from the previous account cannot repopulate a cleared profile',
      () async {
    final response = Completer<BusinessProfileModel>();
    final cubit = CompanyProfileCubit(_ProfileUseCase(response.future));
    addTearDown(cubit.close);
    final preload = cubit.preload();
    cubit.clear();
    final current =
        BusinessProfileModel.fromJson({'id': 'new', 'name': 'New company'});
    cubit.setProfile(current, expectedGeneration: cubit.generation);
    response.complete(
        BusinessProfileModel.fromJson({'id': 'old', 'name': 'Old company'}));
    await preload;
    expect(cubit.state.profile?.id, 'new');
  });

  test(
      'external BLoC setters cannot restore a profile from a previous generation',
      () {
    final cubit = CompanyProfileCubit(_ProfileUseCase(
        Future.value(BusinessProfileModel.fromJson({'id': 'unused'}))));
    addTearDown(cubit.close);
    final beforeRequest = cubit.generation;
    cubit.clear();
    cubit.setProfile(BusinessProfileModel.fromJson({'id': 'old'}),
        expectedGeneration: beforeRequest);
    expect(cubit.state.profile, isNull);
  });
}

class _ProfileUseCase implements GetBusinessProfileUseCase {
  _ProfileUseCase(this.response);
  final Future<BusinessProfileModel> response;
  @override
  Future<BusinessProfileModel> call() => response;
}
