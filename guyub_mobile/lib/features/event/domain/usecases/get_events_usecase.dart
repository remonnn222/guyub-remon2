import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEventsUseCase {
  final EventRepository repository;

  const GetEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call({
    String? filter,
    int? familyId,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getEvents(
      filter: filter,
      familyId: familyId,
      page: page,
      limit: limit,
    );
  }
}
