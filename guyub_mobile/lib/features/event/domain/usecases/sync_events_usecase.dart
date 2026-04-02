import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/event_repository.dart';

class SyncEventsUseCase {
  final EventRepository repository;

  const SyncEventsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.syncOfflineData();
  }
}
