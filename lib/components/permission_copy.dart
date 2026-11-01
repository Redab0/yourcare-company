import 'package:flutter/widgets.dart';
import '../../core/utils/context_extensions.dart';

class PermissionCopy {
  const PermissionCopy(this.title, this.description);
  final String title;
  final String description;
}

PermissionCopy permissionCopy(BuildContext context, String? key) {
  final l10n = context.l10n;
  return switch (key) {
    'users:create' => PermissionCopy(
        l10n.capabilityUsersCreateTitle, l10n.capabilityUsersCreateDescription),
    'users:read' => PermissionCopy(
        l10n.capabilityUsersReadTitle, l10n.capabilityUsersReadDescription),
    'users:update' => PermissionCopy(
        l10n.capabilityUsersUpdateTitle, l10n.capabilityUsersUpdateDescription),
    'users:delete' => PermissionCopy(
        l10n.capabilityUsersDeleteTitle, l10n.capabilityUsersDeleteDescription),
    'business:create' => PermissionCopy(l10n.capabilityBusinessCreateTitle,
        l10n.capabilityBusinessCreateDescription),
    'business:read' => PermissionCopy(l10n.capabilityBusinessReadTitle,
        l10n.capabilityBusinessReadDescription),
    'business:update' => PermissionCopy(l10n.capabilityBusinessUpdateTitle,
        l10n.capabilityBusinessUpdateDescription),
    'business:delete' => PermissionCopy(l10n.capabilityBusinessDeleteTitle,
        l10n.capabilityBusinessDeleteDescription),
    'categories:create' => PermissionCopy(l10n.capabilityCategoriesCreateTitle,
        l10n.capabilityCategoriesCreateDescription),
    'categories:read' => PermissionCopy(l10n.capabilityCategoriesReadTitle,
        l10n.capabilityCategoriesReadDescription),
    'categories:update' => PermissionCopy(l10n.capabilityCategoriesUpdateTitle,
        l10n.capabilityCategoriesUpdateDescription),
    'categories:delete' => PermissionCopy(l10n.capabilityCategoriesDeleteTitle,
        l10n.capabilityCategoriesDeleteDescription),
    'requests:create' => PermissionCopy(l10n.capabilityRequestsCreateTitle,
        l10n.capabilityRequestsCreateDescription),
    'requests:read' => PermissionCopy(l10n.capabilityRequestsReadTitle,
        l10n.capabilityRequestsReadDescription),
    'requests:update' => PermissionCopy(l10n.capabilityRequestsUpdateTitle,
        l10n.capabilityRequestsUpdateDescription),
    'requests:delete' => PermissionCopy(l10n.capabilityRequestsDeleteTitle,
        l10n.capabilityRequestsDeleteDescription),
    'transactions:create' => PermissionCopy(
        l10n.capabilityTransactionsCreateTitle,
        l10n.capabilityTransactionsCreateDescription),
    'transactions:read' => PermissionCopy(l10n.capabilityTransactionsReadTitle,
        l10n.capabilityTransactionsReadDescription),
    'transactions:update' => PermissionCopy(
        l10n.capabilityTransactionsUpdateTitle,
        l10n.capabilityTransactionsUpdateDescription),
    'transactions:delete' => PermissionCopy(
        l10n.capabilityTransactionsDeleteTitle,
        l10n.capabilityTransactionsDeleteDescription),
    'areas:create' => PermissionCopy(
        l10n.capabilityAreasCreateTitle, l10n.capabilityAreasCreateDescription),
    'areas:read' => PermissionCopy(
        l10n.capabilityAreasReadTitle, l10n.capabilityAreasReadDescription),
    'areas:update' => PermissionCopy(
        l10n.capabilityAreasUpdateTitle, l10n.capabilityAreasUpdateDescription),
    'areas:delete' => PermissionCopy(
        l10n.capabilityAreasDeleteTitle, l10n.capabilityAreasDeleteDescription),
    'email:create' => PermissionCopy(
        l10n.capabilityEmailCreateTitle, l10n.capabilityEmailCreateDescription),
    'email:read' => PermissionCopy(
        l10n.capabilityEmailReadTitle, l10n.capabilityEmailReadDescription),
    'email:update' => PermissionCopy(
        l10n.capabilityEmailUpdateTitle, l10n.capabilityEmailUpdateDescription),
    'email:delete' => PermissionCopy(
        l10n.capabilityEmailDeleteTitle, l10n.capabilityEmailDeleteDescription),
    'chat:create' => PermissionCopy(
        l10n.capabilityChatCreateTitle, l10n.capabilityChatCreateDescription),
    'chat:read' => PermissionCopy(
        l10n.capabilityChatReadTitle, l10n.capabilityChatReadDescription),
    'chat:update' => PermissionCopy(
        l10n.capabilityChatUpdateTitle, l10n.capabilityChatUpdateDescription),
    'chat:delete' => PermissionCopy(
        l10n.capabilityChatDeleteTitle, l10n.capabilityChatDeleteDescription),
    'teams:create' => PermissionCopy(
        l10n.capabilityTeamsCreateTitle, l10n.capabilityTeamsCreateDescription),
    'teams:read' => PermissionCopy(
        l10n.capabilityTeamsReadTitle, l10n.capabilityTeamsReadDescription),
    'teams:update' => PermissionCopy(
        l10n.capabilityTeamsUpdateTitle, l10n.capabilityTeamsUpdateDescription),
    'teams:delete' => PermissionCopy(
        l10n.capabilityTeamsDeleteTitle, l10n.capabilityTeamsDeleteDescription),
    'permissions:create' => PermissionCopy(
        l10n.capabilityPermissionsCreateTitle,
        l10n.capabilityPermissionsCreateDescription),
    'permissions:read' => PermissionCopy(l10n.capabilityPermissionsReadTitle,
        l10n.capabilityPermissionsReadDescription),
    'permissions:update' => PermissionCopy(
        l10n.capabilityPermissionsUpdateTitle,
        l10n.capabilityPermissionsUpdateDescription),
    'permissions:delete' => PermissionCopy(
        l10n.capabilityPermissionsDeleteTitle,
        l10n.capabilityPermissionsDeleteDescription),
    'staff:create' => PermissionCopy(
        l10n.capabilityStaffCreateTitle, l10n.capabilityStaffCreateDescription),
    'staff:read' => PermissionCopy(
        l10n.capabilityStaffReadTitle, l10n.capabilityStaffReadDescription),
    'staff:update' => PermissionCopy(
        l10n.capabilityStaffUpdateTitle, l10n.capabilityStaffUpdateDescription),
    'staff:delete' => PermissionCopy(
        l10n.capabilityStaffDeleteTitle, l10n.capabilityStaffDeleteDescription),
    'housekeeping_pricing:create' => PermissionCopy(
        l10n.capabilityHousekeepingPricingCreateTitle,
        l10n.capabilityHousekeepingPricingCreateDescription),
    'housekeeping_pricing:read' => PermissionCopy(
        l10n.capabilityHousekeepingPricingReadTitle,
        l10n.capabilityHousekeepingPricingReadDescription),
    'housekeeping_pricing:update' => PermissionCopy(
        l10n.capabilityHousekeepingPricingUpdateTitle,
        l10n.capabilityHousekeepingPricingUpdateDescription),
    'housekeeping_pricing:delete' => PermissionCopy(
        l10n.capabilityHousekeepingPricingDeleteTitle,
        l10n.capabilityHousekeepingPricingDeleteDescription),
    'cleaner_availability:create' => PermissionCopy(
        l10n.capabilityCleanerAvailabilityCreateTitle,
        l10n.capabilityCleanerAvailabilityCreateDescription),
    'cleaner_availability:read' => PermissionCopy(
        l10n.capabilityCleanerAvailabilityReadTitle,
        l10n.capabilityCleanerAvailabilityReadDescription),
    'cleaner_availability:update' => PermissionCopy(
        l10n.capabilityCleanerAvailabilityUpdateTitle,
        l10n.capabilityCleanerAvailabilityUpdateDescription),
    'cleaner_availability:delete' => PermissionCopy(
        l10n.capabilityCleanerAvailabilityDeleteTitle,
        l10n.capabilityCleanerAvailabilityDeleteDescription),
    'auto_bid:create' => PermissionCopy(l10n.capabilityAutoBidCreateTitle,
        l10n.capabilityAutoBidCreateDescription),
    'auto_bid:read' => PermissionCopy(
        l10n.capabilityAutoBidReadTitle, l10n.capabilityAutoBidReadDescription),
    'auto_bid:update' => PermissionCopy(l10n.capabilityAutoBidUpdateTitle,
        l10n.capabilityAutoBidUpdateDescription),
    'auto_bid:delete' => PermissionCopy(l10n.capabilityAutoBidDeleteTitle,
        l10n.capabilityAutoBidDeleteDescription),
    'company_requests:read' => PermissionCopy(
        l10n.capabilityCompanyRequestsReadTitle,
        l10n.capabilityCompanyRequestsReadDescription),
    'company_requests:update' => PermissionCopy(
        l10n.capabilityCompanyRequestsUpdateTitle,
        l10n.capabilityCompanyRequestsUpdateDescription),
    'available_requests:read' => PermissionCopy(
        l10n.capabilityAvailableRequestsReadTitle,
        l10n.capabilityAvailableRequestsReadDescription),
    'upload:create' => PermissionCopy(l10n.capabilityUploadCreateTitle,
        l10n.capabilityUploadCreateDescription),
    'upload:delete' => PermissionCopy(l10n.capabilityUploadDeleteTitle,
        l10n.capabilityUploadDeleteDescription),
    'company_profile:read' => PermissionCopy(
        l10n.capabilityCompanyProfileReadTitle,
        l10n.capabilityCompanyProfileReadDescription),
    'company_profile:update' => PermissionCopy(
        l10n.capabilityCompanyProfileUpdateTitle,
        l10n.capabilityCompanyProfileUpdateDescription),
    'reports:read' => PermissionCopy(
        l10n.capabilityReportsReadTitle, l10n.capabilityReportsReadDescription),
    'company_requests:create' => PermissionCopy(
        l10n.capabilityCompanyRequestsCreateTitle,
        l10n.capabilityCompanyRequestsCreateDescription),
    'company_requests:delete' => PermissionCopy(
        l10n.capabilityCompanyRequestsDeleteTitle,
        l10n.capabilityCompanyRequestsDeleteDescription),
    'company_requests:statistics' => PermissionCopy(
        l10n.capabilityCompanyRequestsStatisticsTitle,
        l10n.capabilityCompanyRequestsStatisticsDescription),
    'available_requests_browse' => PermissionCopy(
        l10n.capabilityAvailableRequestsBrowseTitle,
        l10n.capabilityAvailableRequestsBrowseDescription),
    'available_requests_brows' => PermissionCopy(
        l10n.capabilityAvailableRequestsBrowsTitle,
        l10n.capabilityAvailableRequestsBrowsDescription),
    _ => PermissionCopy(
        l10n.permissionOtherTitle, l10n.permissionOtherDescription),
  };
}
