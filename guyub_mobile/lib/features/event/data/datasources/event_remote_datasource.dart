import 'package:dio/dio.dart';
import 'package:guyub_mobile/features/event/domain/repositories/event_repository.dart';
import '../../../../config/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents({
    String? filter,
    int? familyId,
    int page = 1,
    int limit = 20,
  });
  Future<EventModel> getEventById(int id);
  Future<EventModel> createEvent(CreateEventParams params);
  Future<EventModel> updateEvent(int id, UpdateEventParams params);
  Future<void> deleteEvent(int id);
  Future<EventModel> approveEvent(int id);
  Future<EventModel> rejectEvent(int id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final ApiClient apiClient;

  EventRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EventModel>> getEvents({
    String? filter,
    int? familyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (filter != null) params['filter'] = filter;
      if (familyId != null) params['family_id'] = familyId;

      final response = await apiClient.get(
        ApiConstants.events,
        queryParameters: params,
      );

      final List data = response.data['data'] ?? [];
      return data.map((json) => EventModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Gagal memuat daftar event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> getEventById(int id) async {
    try {
      final endpoint = ApiConstants.buildPath(ApiConstants.eventDetail, {
        'id': id.toString(),
      });
      final response = await apiClient.get(endpoint);
      final data = response.data['data'];
      return EventModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Gagal memuat detail event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> createEvent(CreateEventParams params) async {
    try {
      final response = await apiClient.post(
        ApiConstants.events,
        data: params.toJson(),
      );
      final data = response.data['data'];
      return EventModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Gagal membuat event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> updateEvent(int id, UpdateEventParams params) async {
    try {
      final endpoint = ApiConstants.buildPath(ApiConstants.eventDetail, {
        'id': id.toString(),
      });
      final response = await apiClient.put(endpoint, data: params.toJson());
      final data = response.data['data'];
      return EventModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Gagal memperbarui event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteEvent(int id) async {
    try {
      final endpoint = ApiConstants.buildPath(ApiConstants.eventDetail, {
        'id': id.toString(),
      });
      await apiClient.delete(endpoint);
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Gagal menghapus event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> approveEvent(int id) async {
    try {
      final endpoint = ApiConstants.buildPath(ApiConstants.eventApprove, {
        'id': id.toString(),
      });
      final response = await apiClient.patch(endpoint);
      final data = response.data['data'];
      return EventModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Gagal menyetujui event',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EventModel> rejectEvent(int id) async {
    try {
      final endpoint = ApiConstants.buildPath(ApiConstants.eventReject, {
        'id': id.toString(),
      });
      final response = await apiClient.patch(endpoint);
      final data = response.data['data'];
      return EventModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw ServerException(
        message: 'Gagal menolak event',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
