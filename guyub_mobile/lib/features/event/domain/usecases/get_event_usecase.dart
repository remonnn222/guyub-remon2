import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEventUseCase {
  final EventRepository repository;

  const GetEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(int id) {
    return repository.getEventById(id);
  }
}
