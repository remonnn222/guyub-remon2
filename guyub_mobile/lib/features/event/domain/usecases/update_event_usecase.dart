import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository repository;

  const UpdateEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(int id, UpdateEventParams params) {
    return repository.updateEvent(id, params);
  }
}
