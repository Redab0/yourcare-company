import 'package:cleaning_service_driver/data/repositories/home/home_repository.dart';

class FetchHomeDataUseCase {
  final HomeRepository homeRepository;

  FetchHomeDataUseCase(this.homeRepository);

  Future<void> call() async {
    try {
      // return await homeRepository.getServices();
    } catch (e) {
      throw Exception('Fetching services failed ${e.toString()}');
    }
  }
}
