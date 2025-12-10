import '../entities/sight.dart';

abstract class SightsRepository {
  Future<List<Sight>> getSights();
  Future<Sight> getSightById(String id);

}