import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employee_calendar_response.g.dart';

Map<String, int> _intMapFromJson(Map<String, dynamic>? json) {
  final map = <String, int>{};
  if (json == null) return map;
  json.forEach((key, value) {
    map[key] = (value as num?)?.toInt() ?? 0;
  });
  return map;
}

Map<String, dynamic> _intMapToJson(Map<String, int> map) =>
    map.map((k, v) => MapEntry(k, v));

String? _readAssigneeId(Map json, String key) {
  final direct = json['id'];
  if (direct is String) return direct;
  final alt = json['_id'];
  if (alt is String) return alt;
  return null;
}

@JsonSerializable(checked: true)
class EmployeeCalendarResponse {
  final List<CalendarDay>? calendar;
  final CalendarSummary? summary;
  final List<EmployeeSummary>? employeeSummaries;
  final List<TeamSummary>? teamSummaries;
  final DateRange? dateRange;

  const EmployeeCalendarResponse({
    this.calendar,
    this.summary,
    this.employeeSummaries,
    this.teamSummaries,
    this.dateRange,
  });

  factory EmployeeCalendarResponse.fromJson(Map<String, dynamic> json) =>
      _$EmployeeCalendarResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeCalendarResponseToJson(this);
}

@JsonSerializable(checked: true)
class CalendarDay {
  final DateTime? date;
  final String? dayOfWeek;
  final List<CalendarWork>? works;
  final int? totalWorksCount;
  final int? completedCount;
  final int? inProgressCount;
  final int? pendingCount;
  final int? confirmedCount;

  const CalendarDay({
    this.date,
    this.dayOfWeek,
    this.works,
    this.totalWorksCount,
    this.completedCount,
    this.inProgressCount,
    this.pendingCount,
    this.confirmedCount,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarDayToJson(this);
}

@JsonSerializable(checked: true)
class CalendarWork {
  final String? requestId;
  final String? readableId;
  final String? requestType;
  @JsonKey(fromJson: requestStatusFromJson, toJson: requestStatusToJson)
  final RequestStatus requestStatus;
  final DateTime? scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? durationHours;
  final CalendarOption? cleaningDuration;
  final CalendarOption? numberOfCleaners;
  final double? totalPrice;
  final String? specialNotes;
  final CalendarCustomer? customer;
  final List<CalendarAssignee>? assignedCleaners;
  final CalendarTeam? assignedTeam;

  const CalendarWork({
    this.requestId,
    this.readableId,
    this.requestType,
    this.requestStatus = RequestStatus.unknown,
    this.scheduledTime,
    this.startTime,
    this.endTime,
    this.durationHours,
    this.cleaningDuration,
    this.numberOfCleaners,
    this.totalPrice,
    this.specialNotes,
    this.customer,
    this.assignedCleaners,
    this.assignedTeam,
  });

  factory CalendarWork.fromJson(Map<String, dynamic> json) =>
      _$CalendarWorkFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarWorkToJson(this);
}

@JsonSerializable(checked: true)
class CalendarOption {
  final String? titleAr;
  final String? descriptionAr;
  final String? titleEn;
  final String? descriptionEn;
  final double? price;
  @JsonKey(name: '_id')
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CalendarOption({
    this.titleAr,
    this.descriptionAr,
    this.titleEn,
    this.descriptionEn,
    this.price,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory CalendarOption.fromJson(Map<String, dynamic> json) =>
      _$CalendarOptionFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarOptionToJson(this);
}

@JsonSerializable(checked: true)
class CalendarCustomer {
  final String? id;
  final String? name;
  final String? phone;

  const CalendarCustomer({this.id, this.name, this.phone});

  factory CalendarCustomer.fromJson(Map<String, dynamic> json) =>
      _$CalendarCustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarCustomerToJson(this);
}

@JsonSerializable(checked: true)
class CalendarAssignee {
  @JsonKey(readValue: _readAssigneeId)
  final String? id;
  final String? username;
  final String? phone;
  final String? image;

  const CalendarAssignee({this.id, this.username, this.phone, this.image});

  factory CalendarAssignee.fromJson(Map<String, dynamic> json) =>
      _$CalendarAssigneeFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarAssigneeToJson(this);
}

@JsonSerializable(checked: true)
class CalendarTeam {
  final String? id;
  final List<CalendarAssignee>? members;

  const CalendarTeam({this.id, this.members});

  factory CalendarTeam.fromJson(Map<String, dynamic> json) =>
      _$CalendarTeamFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarTeamToJson(this);
}

@JsonSerializable(checked: true)
class CalendarSummary {
  final int? totalWorks;
  final int? completedCount;
  final int? inProgressCount;
  final int? pendingCount;
  final int? confirmedCount;
  final int? canceledCount;
  final double? totalRevenue;
  @JsonKey(fromJson: _intMapFromJson, toJson: _intMapToJson)
  final Map<String, int> worksByType;
  @JsonKey(fromJson: _intMapFromJson, toJson: _intMapToJson)
  final Map<String, int> worksByStatus;

  const CalendarSummary({
    this.totalWorks,
    this.completedCount,
    this.inProgressCount,
    this.pendingCount,
    this.confirmedCount,
    this.canceledCount,
    this.totalRevenue,
    this.worksByType = const {},
    this.worksByStatus = const {},
  });

  factory CalendarSummary.fromJson(Map<String, dynamic> json) =>
      _$CalendarSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarSummaryToJson(this);
}

@JsonSerializable(checked: true)
class EmployeeSummary {
  final CalendarAssignee? employee;
  final int? totalWorks;
  final int? completedWorks;
  final int? inProgressWorks;
  final int? pendingWorks;
  final int? confirmedWorks;
  final double? totalRevenue;
  @JsonKey(fromJson: _intMapFromJson, toJson: _intMapToJson)
  final Map<String, int> worksByType;

  const EmployeeSummary({
    this.employee,
    this.totalWorks,
    this.completedWorks,
    this.inProgressWorks,
    this.pendingWorks,
    this.confirmedWorks,
    this.totalRevenue,
    this.worksByType = const {},
  });

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) =>
      _$EmployeeSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeSummaryToJson(this);
}

@JsonSerializable(checked: true)
class TeamSummary {
  final CalendarTeam? team;
  final int? totalWorks;
  final int? completedWorks;
  final int? inProgressWorks;
  final int? pendingWorks;
  final int? confirmedWorks;
  final double? totalRevenue;
  @JsonKey(fromJson: _intMapFromJson, toJson: _intMapToJson)
  final Map<String, int> worksByType;

  const TeamSummary({
    this.team,
    this.totalWorks,
    this.completedWorks,
    this.inProgressWorks,
    this.pendingWorks,
    this.confirmedWorks,
    this.totalRevenue,
    this.worksByType = const {},
  });

  factory TeamSummary.fromJson(Map<String, dynamic> json) =>
      _$TeamSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$TeamSummaryToJson(this);
}

@JsonSerializable(checked: true)
class DateRange {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRange({this.startDate, this.endDate});

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);
  Map<String, dynamic> toJson() => _$DateRangeToJson(this);
}
