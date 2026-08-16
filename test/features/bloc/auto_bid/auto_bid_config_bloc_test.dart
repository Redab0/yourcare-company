import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_categories.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:cleaning_service_driver/data/repositories/auto_bid/auto_bid_categories_repository.dart';
import 'package:cleaning_service_driver/data/repositories/auto_bid/auto_bid_config_repository.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/get_auto_bid_categories_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/get_auto_bid_config_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/upsert_auto_bid_config_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/auto_bid/auto_bid_config_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/auto_bid/auto_bid_config_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads only the deep-cleaning categories and config', () async {
    final categories = AutoBidDeepCleaningCategories.fromJson({
      'departmentType': [
        {
          'id': 'house-id',
          'titleEn': 'House',
          'options': {
            'numberOfFloors': [
              {'id': 'floor-id', 'titleEn': '1 Floor'},
            ],
          },
        },
      ],
    });
    final config = AutoBidConfig.fromJson({
      'serviceType': 'deepCleaning',
      'isEnabled': true,
      'deepCleaningPricing': {
        'numberOfFloors': [
          {
            'categoryOptionId': 'floor-id',
            'price': 90,
            'expectedTimeInDays': 2,
          },
        ],
      },
    });
    final categoriesRepository = _FakeCategoriesRepository(categories);
    final configRepository = _FakeConfigRepository(config);
    final bloc = AutoBidConfigBloc(
      getCategoriesUseCase: GetAutoBidCategoriesUseCase(categoriesRepository),
      getConfigUseCase: GetAutoBidConfigUseCase(configRepository),
      upsertConfigUseCase: UpsertAutoBidConfigUseCase(configRepository),
      loader: _FakeLoadingController(),
    );
    addTearDown(bloc.close);

    final completed = bloc.stream.firstWhere((state) => !state.isLoadingDeep);
    bloc.add(const LoadAutoBidConfigs());
    final state = await completed.timeout(const Duration(seconds: 2));

    expect(state.error, isNull);
    expect(state.deepCategories.departmentTypes.single.id, 'house-id');
    expect(state.deepCleaningPricing.numberOfFloors.single.price, 90);
    expect(
      state.deepCleaningPricing.numberOfFloors.single.expectedTimeInDays,
      2,
    );
    expect(state.deepEnabled, isTrue);
    expect(categoriesRepository.deepCleaningCalls, 1);
    expect(categoriesRepository.upholsteryCalls, 0);
    expect(configRepository.requestedServiceTypes, ['deepCleaning']);
  });
}

class _FakeCategoriesRepository implements AutoBidCategoriesRepository {
  final AutoBidDeepCleaningCategories categories;
  int deepCleaningCalls = 0;
  int upholsteryCalls = 0;

  _FakeCategoriesRepository(this.categories);

  @override
  Future<AutoBidDeepCleaningCategories?> getDeepCleaningCategories(
    String serviceType,
  ) async {
    deepCleaningCalls++;
    return categories;
  }

  @override
  Future<AutoBidUpholsteryCategories?> getUpholsteryCategories(
    String serviceType,
  ) async {
    upholsteryCalls++;
    return AutoBidUpholsteryCategories.empty();
  }
}

class _FakeConfigRepository implements AutoBidConfigRepository {
  final AutoBidConfig config;
  final List<String> requestedServiceTypes = [];

  _FakeConfigRepository(this.config);

  @override
  Future<AutoBidConfig?> getAutoBidConfig(String serviceType) async {
    requestedServiceTypes.add(serviceType);
    return config;
  }

  @override
  Future<AutoBidConfig> upsertAutoBidConfig(
    AutoBidConfigRequest request,
  ) async {
    return config;
  }
}

class _FakeLoadingController implements LoadingController {
  @override
  void hide([String tag = 'global']) {}

  @override
  void show([String tag = 'global']) {}
}
