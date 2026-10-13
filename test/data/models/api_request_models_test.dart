import 'package:cleaning_service_driver/data/models/auth/login_request.dart';
import 'package:cleaning_service_driver/data/models/auth/registration_request.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:cleaning_service_driver/data/models/chats/create_conversation_request.dart';
import 'package:cleaning_service_driver/data/models/chats/send_chat_message_request.dart';
import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';
import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing_discount.dart';
import 'package:cleaning_service_driver/data/models/profile/custom_service_item_request.dart';
import 'package:cleaning_service_driver/data/models/profile/update_covered_service_items_request.dart';
import 'package:cleaning_service_driver/data/models/profile/update_custom_service_item_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth request models preserve backend field names', () {
    final login = LoginRequest(
      email: 'manager@example.com',
      password: 'secret',
      deviceId: 'device-1',
    );
    final registration = RegistrationRequest(
      name: 'Manager',
      email: 'manager@example.com',
      password: 'secret',
      phone: '12345678',
      deviceId: 'device-1',
    );

    expect(login.toJson()['device_id'], 'device-1');
    expect(login.toJson(), isNot(contains('deviceId')));
    expect(registration.toJson()['device_id'], 'device-1');
    expect(registration.toJson(), isNot(contains('deviceId')));
  });

  test('chat request models use generated payloads', () {
    expect(
      CreateConversationRequest(requestId: 'HK143').toJson(),
      {'requestId': 'HK143'},
    );
    expect(CreateConversationRequest(requestId: ' ').toJson(), isEmpty);
    expect(
      const SendChatMessageRequest(
        conversationId: 'conversation-1',
        content: 'Hello',
      ).toJson(),
      {
        'conversationId': 'conversation-1',
        'content': 'Hello',
        'type': 'text',
      },
    );
  });

  test('profile mutation request models match their DTOs', () {
    expect(
      const UpdateCoveredServiceItemsRequest(['item-1']).toJson(),
      {
        'serviceItemIds': ['item-1'],
      },
    );
    expect(
      const CustomServiceItemRequest(
        serviceType: 'houseCleaning',
        titleEn: 'Balcony cleaning',
        titleAr: 'Balcony cleaning Arabic',
      ).toJson(),
      {
        'serviceType': 'houseCleaning',
        'titleEn': 'Balcony cleaning',
        'titleAr': 'Balcony cleaning Arabic',
      },
    );
    expect(
      const UpdateCustomServiceItemRequest(
        titleEn: 'Updated title',
        titleAr: 'Updated Arabic title',
      ).toJson(),
      {
        'titleEn': 'Updated title',
        'titleAr': 'Updated Arabic title',
      },
    );
  });

  test('auto-bid request omits response-only labels', () {
    const request = AutoBidConfigRequest(
      serviceType: 'deepCleaning',
      isEnabled: true,
      deepCleaningPricing: AutoBidDeepCleaningPricing(
        departmentTypes: [
          AutoBidOption(
            categoryOptionId: 'option-1',
            price: 10,
            titleEn: 'Apartment',
          ),
        ],
        bedrooms: [],
        bathrooms: [],
        kitchens: [],
        livingRooms: [],
        numberOfFloors: [],
        sizeOptions: [],
      ),
    );

    final json = request.toJson();
    final deepCleaning = json['deepCleaningPricing'] as Map<String, dynamic>;
    final option = (deepCleaning['departmentTypes'] as List).single
        as Map<String, dynamic>;
    expect(option, {'categoryOptionId': 'option-1', 'price': 10.0});
    expect(option, isNot(contains('titleEn')));
    expect(json, isNot(contains('upholsteryPricing')));
  });

  test('housekeeping request serializes dedicated nested DTOs only', () {
    final request = HousekeepingPricingRequest(
      areaFees: const [
        HousekeepingAreaFee(areaId: 'area-1', fee: 2.5),
      ],
      isActive: true,
      cleaningProductsPrice: 5,
      singlePricingModel: const HousekeepingSinglePricingModel(
        isActive: true,
        basePricePerCleanerPerHour: 3,
      ),
      multiplePricingModel: const HousekeepingMultiplePricingModel(
        isActive: false,
        options: [
          HousekeepingPricingOption(optionId: 'duration-1', price: 10),
        ],
      ),
      frequencyDiscounts: const [
        HousekeepingPricingDiscount(
          optionId: 'frequency-1',
          discountPercentage: 15,
        ),
      ],
    );

    expect(request.toJson(), {
      'areaFees': [
        {'areaId': 'area-1', 'fee': 2.5},
      ],
      'isActive': true,
      'cleaningProductsPrice': 5.0,
      'singlePricingModel': {
        'isActive': true,
        'basePricePerCleanerPerHour': 3.0,
      },
      'multiplePricingModel': {
        'isActive': false,
        'options': [
          {'optionId': 'duration-1', 'price': 10.0},
        ],
      },
      'frequencyDiscounts': [
        {'optionId': 'frequency-1', 'discountPercentage': 15.0},
      ],
    });
  });
}
