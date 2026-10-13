import 'package:json_annotation/json_annotation.dart';

part 'request_campaign.g.dart';

/// The campaign snapshot attached to this order, not the current promotion.
@JsonSerializable(checked: true)
class RequestCampaign {
  final String? campaignId;
  final String? applicationId;
  final String? name;
  final String? type;
  final double? percentage;
  final String? fundedBy;
  final String? state;
  final bool? registrationGiftApplied;
  final double? discountKwd;
  final double? cashbackKwd;
  final double? cashbackSparkle;
  final double? sparkleworth;
  final double? reversedCashbackKwd;
  final bool? honoredAfterEnd;
  final double? amountKwd;
  final String? businessId;
  final String? serviceType;
  final bool? onlyOnce;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool? excludesCashback;

  const RequestCampaign({
    this.campaignId,
    this.applicationId,
    this.name,
    this.type,
    this.percentage,
    this.fundedBy,
    this.state,
    this.registrationGiftApplied,
    this.discountKwd,
    this.cashbackKwd,
    this.cashbackSparkle,
    this.sparkleworth,
    this.reversedCashbackKwd,
    this.honoredAfterEnd,
    this.amountKwd,
    this.businessId,
    this.serviceType,
    this.onlyOnce,
    this.startsAt,
    this.expiresAt,
    this.excludesCashback,
  });

  bool get isReserved => state == 'reserved';
  bool get isApplied => state == 'applied';
  bool get isActiveBenefit => isReserved || isApplied;

  bool get hasActiveRegistrationGift =>
      type == 'registration_gift' &&
      isActiveBenefit &&
      registrationGiftApplied != false;

  bool get hasActiveDiscount =>
      type == 'discount' &&
      isActiveBenefit &&
      discountKwd != null &&
      discountKwd!.isFinite &&
      discountKwd! > 0;

  bool get hasActiveCashback =>
      type == 'cashback' &&
      isActiveBenefit &&
      cashbackKwd != null &&
      cashbackKwd!.isFinite &&
      cashbackKwd! > 0;

  bool get hasVisibleBenefit =>
      hasActiveRegistrationGift || hasActiveDiscount || hasActiveCashback;

  factory RequestCampaign.fromJson(Map<String, dynamic> json) =>
      _$RequestCampaignFromJson(json);

  Map<String, dynamic> toJson() => _$RequestCampaignToJson(this);
}
