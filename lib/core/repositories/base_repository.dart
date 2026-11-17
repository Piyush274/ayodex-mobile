import '../network/api_client.dart';
import '../network/api_exceptions.dart';
import '../network/api_response.dart';

abstract class BaseRepository {
  final ApiClient apiClient;

  const BaseRepository(this.apiClient);

  Future<T> handleApiCall<T>(Future<ApiResponse<T>> Function() call) async {
    try {
      final response = await call();
      if (response.isSuccess) {
        if (response.data != null) {
          return response.data!;
        }
        if (T == dynamic || T == void) {
          return null as T;
        }
      }
      throw ApiException(
        message: response.getErrorMessage(),
        remark: response.remark,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
