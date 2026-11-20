import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/models/paginated_response.dart';
import 'package:ayodex/core/network/api_client.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import '../models/transaction_model.dart';

class TransactionPageResult {
  final PaginatedResponse<TransactionModel> paginated;
  final List<String> remarks;

  const TransactionPageResult({
    required this.paginated,
    this.remarks = const [],
  });
}

class TransactionRepository extends BaseRepository {
  TransactionRepository(ApiClient apiClient) : super(apiClient);

  Future<TransactionPageResult> getTransactions({
    int page = 1,
    String? search,
    String? type,
    String? remark,
  }) async {
    final Map<String, dynamic> query = {'page': page};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (type != null && type.isNotEmpty && type != 'all') {
      query['trx_type'] = type;
    }
    if (remark != null && remark.isNotEmpty && remark != 'all') {
      query['remark'] = remark;
    }

    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(
        ApiEndpoints.transactions,
        queryParameters: query,
      );
    });

    if (response is Map<String, dynamic>) {
      final dynamic rawTrx = response['transactions'] ?? response['data']?['transactions'] ?? response;
      final paginated = PaginatedResponse<TransactionModel>.fromJson(
        rawTrx,
        (item) => TransactionModel.fromJson(item as Map<String, dynamic>),
      );

      final List<String> remarks = [];
      final rawRemarks = response['remarks'] as List<dynamic>?;
      if (rawRemarks != null) {
        for (final r in rawRemarks) {
          if (r is Map && r['remark'] != null) {
            remarks.add(r['remark'].toString());
          } else if (r is String) {
            remarks.add(r);
          }
        }
      }

      return TransactionPageResult(paginated: paginated, remarks: remarks);
    }

    return TransactionPageResult(
      paginated: PaginatedResponse<TransactionModel>(data: [], currentPage: 1, total: 0),
    );
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransactionRepository(apiClient);
});
