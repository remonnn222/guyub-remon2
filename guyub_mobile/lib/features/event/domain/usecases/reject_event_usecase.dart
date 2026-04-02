import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class RejectEventUseCase {
  final EventRepository repository;

  const RejectEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(int id) {
    return repository.rejectEvent(id);
  }
}
