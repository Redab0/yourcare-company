import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum CompanyProvidedService {
  deepCleaning('deepCleaning'),
  houseCleaning('houseCleaning'),
  upholsteryCleaning('upholsteryCleaning'),
  carWash('carWash');

  final String apiValue;

  const CompanyProvidedService(this.apiValue);

  static CompanyProvidedService? fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final service in values) {
      if (service.apiValue.toLowerCase() == normalized) return service;
    }
    return null;
  }

  static Set<CompanyProvidedService> parseAll(Iterable<String>? values) {
    if (values == null) return const <CompanyProvidedService>{};
    return values.map(fromApiValue).whereType<CompanyProvidedService>().toSet();
  }
}

enum BusinessHomeService {
  upcomingJobs(
    imageAsset: 'assets/images/jobs.png',
    requiredPermissions: [Permission.companyRequestsRead],
    requiredCompanyServices: CompanyProvidedService.values,
  ),
  cleaningRequests(
    imageAsset: 'assets/images/requests.png',
    requiredPermissions: [
      Permission.availableRequestsRead,
      Permission.availableRequestsBrowse,
    ],
    requiredCompanyServices: [CompanyProvidedService.deepCleaning],
  ),
  houseKeepingConfiguration(
    imageAsset: 'assets/images/ic_house_keeping_management.png',
    requiredPermissions: [
      Permission.cleanerAvailabilityRead,
      Permission.cleanerAvailabilityCreate,
      Permission.cleanerAvailabilityUpdate,
      Permission.cleanerAvailabilityDelete,
      Permission.housekeepingPricingRead,
      Permission.housekeepingPricingCreate,
      Permission.housekeepingPricingUpdate,
    ],
    requiredCompanyServices: [CompanyProvidedService.houseCleaning],
  ),
  carWashConfiguration(
    imageAsset: 'assets/images/ic_car_wash_config.png',
    requiredPermissions: [
      Permission.companyProfileRead,
      Permission.companyProfileUpdate,
      Permission.businessRead,
      Permission.businessUpdate,
    ],
    requiredCompanyServices: [CompanyProvidedService.carWash],
  ),
  upholsteryConfiguration(
    imageAsset: 'assets/images/ic_furniture_config.png',
    requiredPermissions: [
      Permission.companyProfileRead,
      Permission.companyProfileUpdate,
      Permission.businessRead,
      Permission.businessUpdate,
    ],
    requiredCompanyServices: [CompanyProvidedService.upholsteryCleaning],
  ),
  autoBidding(
    imageAsset: 'assets/images/ic_requests.png',
    requiredPermissions: [
      Permission.autoBidRead,
      Permission.autoBidCreate,
      Permission.autoBidUpdate,
    ],
    requiredCompanyServices: [
      CompanyProvidedService.deepCleaning,
    ],
  ),
  staffManagement(
    imageAsset: 'assets/images/staff.png',
    requiredPermissions: [
      Permission.staffRead,
      Permission.staffCreate,
      Permission.staffUpdate,
      Permission.teamsRead,
      Permission.teamsCreate,
      Permission.teamsUpdate,
      Permission.permissionsRead,
      Permission.permissionsUpdate,
      Permission.requestsRead,
      Permission.companyRequestsRead,
      Permission.companyRequestsStatistics,
      Permission.availableRequestsRead,
      Permission.availableRequestsBrowse,
      Permission.browsAvailableRequests,
    ],
  ),
  companyProfile(
    imageAsset: 'assets/images/ic_business_profile.png',
    requiredPermissions: [
      Permission.companyProfileRead,
      Permission.companyProfileUpdate,
    ],
  ),
  reports(
    imageAsset: 'assets/images/analytics.png',
    requiredPermissions: [Permission.reportsRead],
  );

  final String imageAsset;
  final List<Permission> requiredPermissions;
  final List<CompanyProvidedService> requiredCompanyServices;

  const BusinessHomeService({
    required this.imageAsset,
    required this.requiredPermissions,
    this.requiredCompanyServices = const [],
  });

  bool canShow({
    required List<PermissionModel> permissions,
    required Set<CompanyProvidedService>? companyServices,
  }) {
    if (!permissions.hasAnyPermission(requiredPermissions)) return false;
    if (requiredCompanyServices.isEmpty) return true;
    if (companyServices == null) return false;
    return requiredCompanyServices.any(companyServices.contains);
  }

  String title(BuildContext context) {
    switch (this) {
      case BusinessHomeService.upcomingJobs:
        return context.l10n.upcoming_jobs;
      case BusinessHomeService.cleaningRequests:
        return context.l10n.cleaning_requests;
      case BusinessHomeService.houseKeepingConfiguration:
        return context.l10n.house_keeping_configuration;
      case BusinessHomeService.carWashConfiguration:
        return context.l10n.car_wash_configuration;
      case BusinessHomeService.upholsteryConfiguration:
        return context.l10n.upholstery_configuration;
      case BusinessHomeService.autoBidding:
        return context.l10n.auto_bidding;
      case BusinessHomeService.staffManagement:
        return context.l10n.staff_management;
      case BusinessHomeService.companyProfile:
        return context.l10n.company_profile;
      case BusinessHomeService.reports:
        return context.l10n.reports;
    }
  }

  String setupGuideDescription(BuildContext context) {
    switch (this) {
      case BusinessHomeService.companyProfile:
        return context.l10n.business_setup_tour_profile;
      case BusinessHomeService.houseKeepingConfiguration:
        return context.l10n.business_setup_tour_housekeeping;
      case BusinessHomeService.carWashConfiguration:
        return context.l10n.business_setup_tour_car_wash;
      case BusinessHomeService.upholsteryConfiguration:
        return context.l10n.business_setup_tour_furniture;
      case BusinessHomeService.autoBidding:
        return context.l10n.business_setup_tour_auto_bid;
      case BusinessHomeService.staffManagement:
        return context.l10n.business_setup_tour_staff;
      case BusinessHomeService.cleaningRequests:
        return context.l10n.business_setup_tour_requests;
      case BusinessHomeService.upcomingJobs:
        return context.l10n.business_setup_tour_jobs;
      case BusinessHomeService.reports:
        return '';
    }
  }

  void open(BuildContext context) {
    switch (this) {
      case BusinessHomeService.upcomingJobs:
        context.pushNamed('jobs-main-screen');
        break;
      case BusinessHomeService.cleaningRequests:
        context.pushNamed('requests-main-screen');
        break;
      case BusinessHomeService.houseKeepingConfiguration:
        context.pushNamed('housekeeping-main-screen');
        break;
      case BusinessHomeService.carWashConfiguration:
        context.pushNamed('car-wash-main-screen');
        break;
      case BusinessHomeService.upholsteryConfiguration:
        context.pushNamed('upholstery-configuration-screen');
        break;
      case BusinessHomeService.autoBidding:
        context.pushNamed('auto-bidding-screen');
        break;
      case BusinessHomeService.staffManagement:
        context.pushNamed('staff-main-screen');
        break;
      case BusinessHomeService.companyProfile:
        context.pushNamed('business-profile-screen');
        break;
      case BusinessHomeService.reports:
        context.pushNamed('statisticsScreen');
        break;
    }
  }
}

const businessSetupTourOrder = <BusinessHomeService>[
  BusinessHomeService.companyProfile,
  BusinessHomeService.houseKeepingConfiguration,
  BusinessHomeService.carWashConfiguration,
  BusinessHomeService.upholsteryConfiguration,
  BusinessHomeService.autoBidding,
  BusinessHomeService.staffManagement,
  BusinessHomeService.cleaningRequests,
  BusinessHomeService.upcomingJobs,
];

List<BusinessHomeService> orderedBusinessSetupTourServices(
  Iterable<BusinessHomeService> visibleServices,
) {
  final visible = visibleServices.toSet();
  return businessSetupTourOrder.where(visible.contains).toList(growable: false);
}
