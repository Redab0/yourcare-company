import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 15, 10);
  final customer = Customer(id: 'customer-id');

  test('reads and trims customer notes for every request type', () {
    final requests = <CleaningRequest>[
      HouseKeepingHistory(
        requestStatus: RequestStatus.confirmed,
        totalPrice: 10,
        createdAt: now,
        updatedAt: now,
        detail: HouseKeepingDetail(specialNotes: '  House note  '),
        scheduledTime: now,
        customer: customer,
      ),
      DeepCleaningHistory(
        requestStatus: RequestStatus.pending,
        totalPrice: 10,
        createdAt: now,
        updatedAt: now,
        detail: DeepCleaningDetail(
          departmentSelection: DeepCleaningDepartmentSelection(
            additionalInformation: '  Deep note  ',
          ),
        ),
        scheduledTime: now,
        customer: customer,
      ),
      CarWashHistory(
        requestStatus: RequestStatus.confirmed,
        totalPrice: 10,
        createdAt: now,
        updatedAt: now,
        customer: customer,
        scheduledTime: now,
        detail: const CarWashHistoryDetail(
          specialNotes: '  Car wash note  ',
        ),
      ),
      UpholsteryCleaningHistory(
        customer: customer,
        requestStatus: RequestStatus.confirmed,
        totalPrice: 10,
        type: 'upholsteryCleaning',
        createdAt: now,
        updatedAt: now,
        upholsteryCleaning: const UpholsteryCleaningDetails(
          specialNotes: '  Furniture note  ',
        ),
        scheduledTime: null,
      ),
    ];

    expect(
      requests.map((request) => request.customerSpecialNotes),
      ['House note', 'Deep note', 'Car wash note', 'Furniture note'],
    );
  });

  test('only furniture hides its schedule in the business app', () {
    final furniture = UpholsteryCleaningHistory(
      customer: customer,
      requestStatus: RequestStatus.confirmed,
      totalPrice: 10,
      type: 'upholsteryCleaning',
      createdAt: now,
      updatedAt: now,
      upholsteryCleaning: const UpholsteryCleaningDetails(),
      scheduledTime: now,
    );
    final carWash = CarWashHistory(
      requestStatus: RequestStatus.confirmed,
      totalPrice: 10,
      createdAt: now,
      updatedAt: now,
      customer: customer,
      scheduledTime: now,
    );

    expect(furniture.showsScheduleInBusinessApp, isFalse);
    expect(carWash.showsScheduleInBusinessApp, isTrue);
  });
}
