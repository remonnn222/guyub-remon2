import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository repository;

  const DeleteEventUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteEvent(id);
  }
}
