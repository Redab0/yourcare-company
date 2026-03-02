abstract class AutoBidConfigEvent {
  const AutoBidConfigEvent();
}

class LoadAutoBidConfigs extends AutoBidConfigEvent {
  const LoadAutoBidConfigs();
}

class ToggleAutoBidEnabled extends AutoBidConfigEvent {
  final String serviceType;
  final bool isEnabled;

  const ToggleAutoBidEnabled({
    required this.serviceType,
    required this.isEnabled,
  });
}

class UpdateDeepCleaningPrice extends AutoBidConfigEvent {
  final String section;
  final String optionId;
  final double price;

  const UpdateDeepCleaningPrice({
    required this.section,
    required this.optionId,
    required this.price,
  });
}


class UpdateDeepCleaningExpectedTime extends AutoBidConfigEvent {
  final String section;
  final String optionId;
  final int? expectedTimeInDays;

  const UpdateDeepCleaningExpectedTime({
    required this.section,
    required this.optionId,
    required this.expectedTimeInDays,
  });
}

class UpdateUpholsteryPrice extends AutoBidConfigEvent {
  final String categoryTypeId;
  final String section;
  final String optionId;
  final double price;

  const UpdateUpholsteryPrice({
    required this.categoryTypeId,
    required this.section,
    required this.optionId,
    required this.price,
  });
}


class UpdateUpholsteryExpectedTime extends AutoBidConfigEvent {
  final String categoryTypeId;
  final String section;
  final String optionId;
  final int? expectedTimeInDays;

  const UpdateUpholsteryExpectedTime({
    required this.categoryTypeId,
    required this.section,
    required this.optionId,
    required this.expectedTimeInDays,
  });
}

class SaveAutoBidConfig extends AutoBidConfigEvent {
  final String serviceType;

  const SaveAutoBidConfig({required this.serviceType});
}
