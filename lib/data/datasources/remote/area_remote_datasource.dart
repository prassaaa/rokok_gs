import '../../../core/network/api_client.dart';
import '../../models/area_model.dart';

/// Remote data source for Area API operations
abstract class AreaRemoteDataSource {
  /// Get all areas
  Future<List<AreaModel>> getAreas();

  /// Get area by ID
  Future<AreaModel> getAreaById(int id);
}

class AreaRemoteDataSourceImpl implements AreaRemoteDataSource {
  final ApiClient _apiClient;

  AreaRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AreaModel>> getAreas() async {
    final response = await _apiClient.dio.get('/areas');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => AreaModel.fromJson(json)).toList();
  }

  @override
  Future<AreaModel> getAreaById(int id) async {
    final response = await _apiClient.dio.get('/areas/$id');
    return AreaModel.fromJson(response.data['data']);
  }
}
