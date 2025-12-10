import '../../entities/sight.dart';
import '../../repositories/sights_repository.dart';

class GetSightsUseCase {
  final SightsRepository repository;
  GetSightsUseCase(this.repository);

  Future<List<Sight>> call() {
    return repository.getSights();
  }
}
