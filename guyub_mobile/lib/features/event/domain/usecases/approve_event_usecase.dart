import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class ApproveEventUseCase {
  final EventRepository repository;

  const ApproveEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(int id) {
    return repository.approveEvent(id);
  }
}
