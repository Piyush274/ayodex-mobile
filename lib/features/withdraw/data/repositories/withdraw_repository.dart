import 'package:dio/dio.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/network/api_exceptions.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/models/paginated_response.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import 'package:ayodex/features/exchange/data/models/currency_model.dart';
import '../models/withdrawal_model.dart';

class WithdrawMethodsResponse {
  final List<CurrencyModel> currencies;
  final bool isWithdrawDisabled;
  final String? message;

  const WithdrawMethodsResponse({
    required this.currencies,
    this.isWithdrawDisabled = false,
    this.message,
  });
}

class WithdrawRepository extends BaseRepository {
  WithdrawRepository(super.apiClient);

  Future<WithdrawMethodsResponse> getWithdrawMethods() async {
    try {
      final response = await handleApiCall(() async {
        return await apiClient.get<dynamic>(ApiEndpoints.withdrawCurrency);
      });

      if (response is Map<String, dynamic>) {
        final dynamic raw = response['currencies'] ?? response['data']?['currencies'] ?? response['data'] ?? response;
        if (raw is List) {
          final currencies = raw.map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>)).toList();
          return WithdrawMethodsResponse(currencies: currencies);
        }
      } else if (response is List) {
        final currencies = response.map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>)).toList();
        return WithdrawMethodsResponse(currencies: currencies);
      }
      return const WithdrawMethodsResponse(currencies: []);
    } on ApiException catch (e) {
      if (e.remark == 'withdraw_disabled') {
        return WithdrawMethodsResponse(
          currencies: [],
          isWithdrawDisabled: true,
          message: e.message,
        );
      }
      rethrow;
    }
  }

  Future<WithdrawalModel> submitWithdraw({
    required int currencyId,
    required Decimal amount,
    required Map<String, dynamic> dynamicFields,
    String? idempotencyKey,
  }) async {
    final Map<String, dynamic> payload = {
      'currency_id': currencyId,
      'amount': amount.toString(),
      ...dynamicFields,
    };

    Options? options;
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      options = Options(headers: {'Idempotency-Key': idempotencyKey});
    }

    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.withdrawSave,
        data: payload,
        options: options,
      );
    });

    if (response is Map<String, dynamic>) {
      final withdrawData = response['withdraw'] ?? response['data']?['withdraw'] ?? response['data'] ?? response;
      return WithdrawalModel.fromJson(withdrawData as Map<String, dynamic>);
    }
    throw Exception('Invalid withdrawal response format');
  }

  Future<PaginatedResponse<WithdrawalModel>> getWithdrawHistory({
    int page = 1,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(
        ApiEndpoints.withdrawHistory,
        queryParameters: queryParams,
      );
    });

    if (response is Map<String, dynamic>) {
      final paginatedData = response['withdrawals'] ?? response['data']?['withdrawals'] ?? response['data'] ?? response;
      return PaginatedResponse<WithdrawalModel>.fromJson(
        paginatedData as Map<String, dynamic>,
        (json) => WithdrawalModel.fromJson(json),
      );
    }
    return const PaginatedResponse<WithdrawalModel>();
  }
}

final withdrawRepositoryProvider = Provider<WithdrawRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return WithdrawRepository(client);
});
