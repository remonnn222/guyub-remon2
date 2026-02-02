import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/family_model.dart';
import '../../domain/repositories/family_repository.dart';

/// Family Remote Data Source Interface
abstract class FamilyRemoteDataSource {
  /// Get all families for current user
  Future<List<FamilyModel>> getFamilies();

  /// Get family by ID
  Future<FamilyModel> getFamilyById(int id);

  /// Get family tree data
  Future<FamilyTreeResponse> getFamilyTree(int familyId);

  /// Create a new family
  Future<FamilyModel> createFamily(CreateFamilyParams params);

  /// Update family
  Future<FamilyModel> updateFamily(int id, UpdateFamilyParams params);

  /// Delete family
  Future<void> deleteFamily(int id);

  /// Join family by invite code
  Future<FamilyModel> joinFamily(String inviteCode);

  /// Get all persons in a family
  Future<List<PersonModel>> getPersons(int familyId);

  /// Get person by ID
  Future<PersonModel> getPersonById(int id);

  /// Create a new person
  Future<PersonModel> createPerson(CreatePersonParams params);

  /// Update person
  Future<PersonModel> updatePerson(int id, UpdatePersonParams params);

  /// Delete person
  Future<void> deletePerson(int id);

  /// Create relationship
  Future<RelationshipModel> createRelationship(CreateRelationshipParams params);

  /// Delete relationship
  Future<void> deleteRelationship(int id);

  /// Update tree positions (batch)
  Future<void> updateTreePositions(int familyId, List<TreePositionModel> positions);
}

/// Family Remote Data Source Implementation
class FamilyRemoteDataSourceImpl implements FamilyRemoteDataSource {
  final ApiClient apiClient;

  FamilyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<FamilyModel>> getFamilies() async {
    try {
      final response = await apiClient.get(ApiEndpoints.families);

      if (response.data['data'] != null) {
        final List<dynamic> familiesJson = response.data['data'];
        return familiesJson.map((json) => FamilyModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FamilyModel> getFamilyById(int id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.families}/$id');

      if (response.data['data'] != null) {
        return FamilyModel.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Family not found');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FamilyTreeResponse> getFamilyTree(int familyId) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.families}/$familyId/tree');

      if (response.data['data'] != null) {
        return FamilyTreeResponse.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Family tree not found');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FamilyModel> createFamily(CreateFamilyParams params) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.families,
        data: params.toJson(),
      );

      if (response.data['data'] != null) {
        return FamilyModel.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Failed to create family');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FamilyModel> updateFamily(int id, UpdateFamilyParams params) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.families}/$id',
        data: params.toJson(),
      );

      if (response.data['data'] != null) {
        return FamilyModel.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Failed to update family');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteFamily(int id) async {
    try {
      await apiClient.delete('${ApiEndpoints.families}/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FamilyModel> joinFamily(String inviteCode) async {
    try {
      final response = await apiClient.post(
        '${ApiEndpoints.families}/join',
        data: {'invite_code': inviteCode},
      );

      if (response.data['data'] != null) {
        return FamilyModel.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Failed to join family');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<PersonModel>> getPersons(int familyId) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.families}/$familyId/persons');

      if (response.data['data'] != null) {
        final List<dynamic> personsJson = response.data['data'];
        return personsJson.map((json) => PersonModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<PersonModel> getPersonById(int id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.persons}/$id');

      if (response.data['data'] != null) {
        return PersonModel.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Person not found');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<PersonModel> createPerson(CreatePersonParams params) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.persons,
        data: params.toJson(),
      );

      if (response.data['data'] != null) {
        return PersonModel.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Failed to create person');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<PersonModel> updatePerson(int id, UpdatePersonParams params) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.persons}/$id',
        data: params.toJson(),
      );

      if (response.data['data'] != null) {
        return PersonModel.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Failed to update person');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deletePerson(int id) async {
    try {
      await apiClient.delete('${ApiEndpoints.persons}/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<RelationshipModel> createRelationship(CreateRelationshipParams params) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.relationships,
        data: params.toJson(),
      );

      if (response.data['data'] != null) {
        return RelationshipModel.fromJson(response.data['data']);
      }
      throw ServerException(message: 'Failed to create relationship');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteRelationship(int id) async {
    try {
      await apiClient.delete('${ApiEndpoints.relationships}/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> updateTreePositions(int familyId, List<TreePositionModel> positions) async {
    try {
      await apiClient.put(
        '${ApiEndpoints.families}/$familyId/positions',
        data: {
          'positions': positions.map((p) => p.toJson()).toList(),
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic e) {
    if (e is ServerException) return e;
    if (e is UnauthorizedException) return e;
    if (e is NetworkException) return e;
    return ServerException(message: e.toString());
  }
}
