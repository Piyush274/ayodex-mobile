import 'package:dio/dio.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/models/paginated_response.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import '../models/bank_model.dart';
import '../models/transfer_model.dart';
import '../models/transfer_quote_model.dart';

class TransferRepository extends BaseRepository {
  TransferRepository(super.apiClient);

  Future<List<BankModel>> getBanks() async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(ApiEndpoints.transferBanks);
    });

    if (response is Map<String, dynamic>) {
      final dynamic raw = response['banks'] ?? response['data']?['banks'] ?? response['data'] ?? response;
      if (raw is List) {
        return raw.map((e) => BankModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } else if (response is List) {
      return response.map((e) => BankModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <BankModel>[];
  }

  Future<String> resolveAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.transferResolveAccount,
        data: {
          'bank_code': bankCode,
          'account_number': accountNumber,
        },
      );
    });

    if (response is Map<String, dynamic>) {
      final accountName = response['account_name'] ?? response['data']?['account_name'];
      if (accountName != null) {
        return accountName.toString();
      }
    }
    return 'Account Verified';
  }

  Future<TransferQuoteModel> createQuote({
    required String destinationType,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required Decimal amount,
  }) async {
    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.transferQuote,
        data: {
          'destination_type': destinationType,
          'bank_code': bankCode,
          'account_number': accountNumber,
          'account_name': accountName,
          'amount': amount.toString(),
        },
      );
    });

    if (response is Map<String, dynamic>) {
      final quoteData = response['quote'] ?? response['data']?['quote'] ?? response['data'] ?? response;
      return TransferQuoteModel.fromJson(quoteData as Map<String, dynamic>);
    }
    throw Exception('Invalid quote response format');
  }

  Future<TransferModel> confirmTransfer({
    required String quoteId,
    required String pin,
    String? twofactorCode,
    String? idempotencyKey,
  }) async {
    final Map<String, dynamic> payload = {
      'quote_id': quoteId,
      'pin': pin,
    };
    if (twofactorCode != null && twofactorCode.isNotEmpty) {
      payload['code'] = twofactorCode;
    }

    Options? options;
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      options = Options(headers: {'Idempotency-Key': idempotencyKey});
    }

    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.transferConfirm,
        data: payload,
        options: options,
      );
    });

    if (response is Map<String, dynamic>) {
      final transferData = response['transfer'] ?? response['data']?['transfer'] ?? response['data'] ?? response;
      return TransferModel.fromJson(transferData as Map<String, dynamic>);
    }
    throw Exception('Invalid transfer response format');
  }

  Future<PaginatedResponse<TransferModel>> getTransferHistory({
    int page = 1,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(
        ApiEndpoints.transferHistory,
        queryParameters: queryParams,
      );
    });

    if (response is Map<String, dynamic>) {
      final paginatedData = response['transfers'] ?? response['data']?['transfers'] ?? response['data'] ?? response;
      return PaginatedResponse<TransferModel>.fromJson(
        paginatedData as Map<String, dynamic>,
        (json) => TransferModel.fromJson(json),
      );
    }
    return const PaginatedResponse<TransferModel>();
  }

  Future<TransferModel> getTransferDetail(String trx) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>('${ApiEndpoints.transferDetail}/$trx');
    });

    if (response is Map<String, dynamic>) {
      final transferData = response['transfer'] ?? response['data']?['transfer'] ?? response['data'] ?? response;
      return TransferModel.fromJson(transferData as Map<String, dynamic>);
    }
    throw Exception('Invalid transfer detail response format');
  }
}

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TransferRepository(client);
});
