// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_calendar_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeCalendarResponse _$EmployeeCalendarResponseFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'EmployeeCalendarResponse',
      json,
      ($checkedConvert) {
        final val = EmployeeCalendarResponse(
          calendar: $checkedConvert(
              'calendar',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => CalendarDay.fromJson(e as Map<String, dynamic>))
                  .toList()),
          summary: $checkedConvert(
              'summary',
              (v) => v == null
                  ? null
                  : CalendarSummary.fromJson(v as Map<String, dynamic>)),
          employeeSummaries: $checkedConvert(
              'employeeSummaries',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      EmployeeSummary.fromJson(e as Map<String, dynamic>))
                  .toList()),
          teamSummaries: $checkedConvert(
              'teamSummaries',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => TeamSummary.fromJson(e as Map<String, dynamic>))
                  .toList()),
          dateRange: $checkedConvert(
              'dateRange',
              (v) => v == null
                  ? null
                  : DateRange.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$EmployeeCalendarResponseToJson(
        EmployeeCalendarResponse instance) =>
    <String, dynamic>{
      'calendar': instance.calendar,
      'summary': instance.summary,
      'employeeSummaries': instance.employeeSummaries,
      'teamSummaries': instance.teamSummaries,
      'dateRange': instance.dateRange,
    };

CalendarDay _$CalendarDayFromJson(Map<String, dynamic> json) => $checkedCreate(
      'CalendarDay',
      json,
      ($checkedConvert) {
        final val = CalendarDay(
          date: $checkedConvert(
              'date', (v) => v == null ? null : DateTime.parse(v as String)),
          dayOfWeek: $checkedConvert('dayOfWeek', (v) => v as String?),
          works: $checkedConvert(
              'works',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => CalendarWork.fromJson(e as Map<String, dynamic>))
                  .toList()),
          totalWorksCount:
              $checkedConvert('totalWorksCount', (v) => (v as num?)?.toInt()),
          completedCount:
              $checkedConvert('completedCount', (v) => (v as num?)?.toInt()),
          inProgressCount:
              $checkedConvert('inProgressCount', (v) => (v as num?)?.toInt()),
          pendingCount:
              $checkedConvert('pendingCount', (v) => (v as num?)?.toInt()),
          confirmedCount:
              $checkedConvert('confirmedCount', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$CalendarDayToJson(CalendarDay instance) =>
    <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'dayOfWeek': instance.dayOfWeek,
      'works': instance.works,
      'totalWorksCount': instance.totalWorksCount,
      'completedCount': instance.completedCount,
      'inProgressCount': instance.inProgressCount,
      'pendingCount': instance.pendingCount,
      'confirmedCount': instance.confirmedCount,
    };

CalendarWork _$CalendarWorkFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CalendarWork',
      json,
      ($checkedConvert) {
        final val = CalendarWork(
          requestId: $checkedConvert('requestId', (v) => v as String?),
          readableId: $checkedConvert('readableId', (v) => v as String?),
          requestType: $checkedConvert('requestType', (v) => v as String?),
          requestStatus: $checkedConvert(
              'requestStatus',
              (v) => v == null
                  ? RequestStatus.unknown
                  : requestStatusFromJson(v as String?)),
          scheduledTime: $checkedConvert('scheduledTime',
              (v) => v == null ? null : DateTime.parse(v as String)),
          startTime: $checkedConvert('startTime',
              (v) => v == null ? null : DateTime.parse(v as String)),
          endTime: $checkedConvert(
              'endTime', (v) => v == null ? null : DateTime.parse(v as String)),
          durationHours:
              $checkedConvert('durationHours', (v) => (v as num?)?.toInt()),
          cleaningDuration: $checkedConvert(
              'cleaningDuration',
              (v) => v == null
                  ? null
                  : CalendarOption.fromJson(v as Map<String, dynamic>)),
          numberOfCleaners: $checkedConvert(
              'numberOfCleaners',
              (v) => v == null
                  ? null
                  : CalendarOption.fromJson(v as Map<String, dynamic>)),
          totalPrice:
              $checkedConvert('totalPrice', (v) => (v as num?)?.toDouble()),
          specialNotes: $checkedConvert('specialNotes', (v) => v as String?),
          customer: $checkedConvert(
              'customer',
              (v) => v == null
                  ? null
                  : CalendarCustomer.fromJson(v as Map<String, dynamic>)),
          assignedCleaners: $checkedConvert(
              'assignedCleaners',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      CalendarAssignee.fromJson(e as Map<String, dynamic>))
                  .toList()),
          assignedTeam: $checkedConvert(
              'assignedTeam',
              (v) => v == null
                  ? null
                  : CalendarTeam.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$CalendarWorkToJson(CalendarWork instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'readableId': instance.readableId,
      'requestType': instance.requestType,
      'requestStatus': requestStatusToJson(instance.requestStatus),
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'durationHours': instance.durationHours,
      'cleaningDuration': instance.cleaningDuration,
      'numberOfCleaners': instance.numberOfCleaners,
      'totalPrice': instance.totalPrice,
      'specialNotes': instance.specialNotes,
      'customer': instance.customer,
      'assignedCleaners': instance.assignedCleaners,
      'assignedTeam': instance.assignedTeam,
    };

CalendarOption _$CalendarOptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CalendarOption',
      json,
      ($checkedConvert) {
        final val = CalendarOption(
          titleAr: $checkedConvert('titleAr', (v) => v as String?),
          descriptionAr: $checkedConvert('descriptionAr', (v) => v as String?),
          titleEn: $checkedConvert('titleEn', (v) => v as String?),
          descriptionEn: $checkedConvert('descriptionEn', (v) => v as String?),
          price: $checkedConvert('price', (v) => (v as num?)?.toDouble()),
          id: $checkedConvert('_id', (v) => v as String?),
          createdAt: $checkedConvert('createdAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          updatedAt: $checkedConvert('updatedAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {'id': '_id'},
    );

Map<String, dynamic> _$CalendarOptionToJson(CalendarOption instance) =>
    <String, dynamic>{
      'titleAr': instance.titleAr,
      'descriptionAr': instance.descriptionAr,
      'titleEn': instance.titleEn,
      'descriptionEn': instance.descriptionEn,
      'price': instance.price,
      '_id': instance.id,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

CalendarCustomer _$CalendarCustomerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CalendarCustomer',
      json,
      ($checkedConvert) {
        final val = CalendarCustomer(
          id: $checkedConvert('id', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String?),
          phone: $checkedConvert('phone', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CalendarCustomerToJson(CalendarCustomer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
    };

CalendarAssignee _$CalendarAssigneeFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CalendarAssignee',
      json,
      ($checkedConvert) {
        final val = CalendarAssignee(
          id: $checkedConvert(
            'id',
            (v) => v as String?,
            readValue: _readAssigneeId,
          ),
          username: $checkedConvert('username', (v) => v as String?),
          phone: $checkedConvert('phone', (v) => v as String?),
          image: $checkedConvert('image', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CalendarAssigneeToJson(CalendarAssignee instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'phone': instance.phone,
      'image': instance.image,
    };

CalendarTeam _$CalendarTeamFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CalendarTeam',
      json,
      ($checkedConvert) {
        final val = CalendarTeam(
          id: $checkedConvert('id', (v) => v as String?),
          members: $checkedConvert(
              'members',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      CalendarAssignee.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$CalendarTeamToJson(CalendarTeam instance) =>
    <String, dynamic>{
      'id': instance.id,
      'members': instance.members,
    };

CalendarSummary _$CalendarSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CalendarSummary',
      json,
      ($checkedConvert) {
        final val = CalendarSummary(
          totalWorks:
              $checkedConvert('totalWorks', (v) => (v as num?)?.toInt()),
          completedCount:
              $checkedConvert('completedCount', (v) => (v as num?)?.toInt()),
          inProgressCount:
              $checkedConvert('inProgressCount', (v) => (v as num?)?.toInt()),
          pendingCount:
              $checkedConvert('pendingCount', (v) => (v as num?)?.toInt()),
          confirmedCount:
              $checkedConvert('confirmedCount', (v) => (v as num?)?.toInt()),
          canceledCount:
              $checkedConvert('canceledCount', (v) => (v as num?)?.toInt()),
          totalRevenue:
              $checkedConvert('totalRevenue', (v) => (v as num?)?.toDouble()),
          worksByType: $checkedConvert(
              'worksByType',
              (v) => v == null
                  ? const {}
                  : _intMapFromJson(v as Map<String, dynamic>?)),
          worksByStatus: $checkedConvert(
              'worksByStatus',
              (v) => v == null
                  ? const {}
                  : _intMapFromJson(v as Map<String, dynamic>?)),
        );
        return val;
      },
    );

Map<String, dynamic> _$CalendarSummaryToJson(CalendarSummary instance) =>
    <String, dynamic>{
      'totalWorks': instance.totalWorks,
      'completedCount': instance.completedCount,
      'inProgressCount': instance.inProgressCount,
      'pendingCount': instance.pendingCount,
      'confirmedCount': instance.confirmedCount,
      'canceledCount': instance.canceledCount,
      'totalRevenue': instance.totalRevenue,
      'worksByType': _intMapToJson(instance.worksByType),
      'worksByStatus': _intMapToJson(instance.worksByStatus),
    };

EmployeeSummary _$EmployeeSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'EmployeeSummary',
      json,
      ($checkedConvert) {
        final val = EmployeeSummary(
          employee: $checkedConvert(
              'employee',
              (v) => v == null
                  ? null
                  : CalendarAssignee.fromJson(v as Map<String, dynamic>)),
          totalWorks:
              $checkedConvert('totalWorks', (v) => (v as num?)?.toInt()),
          completedWorks:
              $checkedConvert('completedWorks', (v) => (v as num?)?.toInt()),
          inProgressWorks:
              $checkedConvert('inProgressWorks', (v) => (v as num?)?.toInt()),
          pendingWorks:
              $checkedConvert('pendingWorks', (v) => (v as num?)?.toInt()),
          confirmedWorks:
              $checkedConvert('confirmedWorks', (v) => (v as num?)?.toInt()),
          totalRevenue:
              $checkedConvert('totalRevenue', (v) => (v as num?)?.toDouble()),
          worksByType: $checkedConvert(
              'worksByType',
              (v) => v == null
                  ? const {}
                  : _intMapFromJson(v as Map<String, dynamic>?)),
        );
        return val;
      },
    );

Map<String, dynamic> _$EmployeeSummaryToJson(EmployeeSummary instance) =>
    <String, dynamic>{
      'employee': instance.employee,
      'totalWorks': instance.totalWorks,
      'completedWorks': instance.completedWorks,
      'inProgressWorks': instance.inProgressWorks,
      'pendingWorks': instance.pendingWorks,
      'confirmedWorks': instance.confirmedWorks,
      'totalRevenue': instance.totalRevenue,
      'worksByType': _intMapToJson(instance.worksByType),
    };

TeamSummary _$TeamSummaryFromJson(Map<String, dynamic> json) => $checkedCreate(
      'TeamSummary',
      json,
      ($checkedConvert) {
        final val = TeamSummary(
          team: $checkedConvert(
              'team',
              (v) => v == null
                  ? null
                  : CalendarTeam.fromJson(v as Map<String, dynamic>)),
          totalWorks:
              $checkedConvert('totalWorks', (v) => (v as num?)?.toInt()),
          completedWorks:
              $checkedConvert('completedWorks', (v) => (v as num?)?.toInt()),
          inProgressWorks:
              $checkedConvert('inProgressWorks', (v) => (v as num?)?.toInt()),
          pendingWorks:
              $checkedConvert('pendingWorks', (v) => (v as num?)?.toInt()),
          confirmedWorks:
              $checkedConvert('confirmedWorks', (v) => (v as num?)?.toInt()),
          totalRevenue:
              $checkedConvert('totalRevenue', (v) => (v as num?)?.toDouble()),
          worksByType: $checkedConvert(
              'worksByType',
              (v) => v == null
                  ? const {}
                  : _intMapFromJson(v as Map<String, dynamic>?)),
        );
        return val;
      },
    );

Map<String, dynamic> _$TeamSummaryToJson(TeamSummary instance) =>
    <String, dynamic>{
      'team': instance.team,
      'totalWorks': instance.totalWorks,
      'completedWorks': instance.completedWorks,
      'inProgressWorks': instance.inProgressWorks,
      'pendingWorks': instance.pendingWorks,
      'confirmedWorks': instance.confirmedWorks,
      'totalRevenue': instance.totalRevenue,
      'worksByType': _intMapToJson(instance.worksByType),
    };

DateRange _$DateRangeFromJson(Map<String, dynamic> json) => $checkedCreate(
      'DateRange',
      json,
      ($checkedConvert) {
        final val = DateRange(
          startDate: $checkedConvert('startDate',
              (v) => v == null ? null : DateTime.parse(v as String)),
          endDate: $checkedConvert(
              'endDate', (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };
