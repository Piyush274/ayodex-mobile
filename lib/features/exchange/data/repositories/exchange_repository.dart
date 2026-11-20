import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/models/dynamic_form_model.dart';
import 'package:ayodex/core/models/paginated_response.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';
import '../models/currency_model.dart';
import '../models/exchange_model.dart';

class ExchangePreviewResult {
  final ExchangeModel exchange;
  final DynamicFormModel? requiredData;

  const ExchangePreviewResult({
    required this.exchange,
    this.requiredData,
  });
}

class ExchangeConfirmResult {
  final bool isAutomatic;
  final String? redirectUrl;

  const ExchangeConfirmResult({
    required this.isAutomatic,
    this.redirectUrl,
  });
}

class ManualExchangeInstructions {
  final String? instructions;
  final DynamicFormModel? requiredData;

  const ManualExchangeInstructions({
    this.instructions,
    this.requiredData,
  });
}

class ExchangeRepository extends BaseRepository {
  ExchangeRepository(super.apiClient);

  /// Fetch list of supported currencies and their rates
  Future<List<CurrencyModel>> getCurrencies() async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(ApiEndpoints.currencyList);
    });

    if (response is Map<String, dynamic>) {
      final rawList = response['currencies'] ?? response['data']?['currencies'] ?? [];
      if (rawList is List) {
        return rawList
            .whereType<Map<String, dynamic>>()
            .map((c) => CurrencyModel.fromJson(c))
            .toList();
      }
    } else if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((c) => CurrencyModel.fromJson(c))
          .toList();
    }
    return [];
  }

  /// Create new currency exchange order
  Future<ExchangeModel> createExchange({
    required Decimal sendingAmount,
    required int sendingCurrencyId,
    required int receivingCurrencyId,
  }) async {
    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.exchangeCreate,
        data: {
          'sending_amount': sendingAmount.toString(),
          'sending_currency': sendingCurrencyId,
          'receiving_currency': receivingCurrencyId,
        },
      );
    });

    if (response is Map<String, dynamic>) {
      final dynamic rawExchange = response['exchange'] ?? response['data']?['exchange'] ?? response;
      if (rawExchange is Map<String, dynamic>) {
        return ExchangeModel.fromJson(rawExchange);
      }
    }
    throw Exception('Failed to parse created exchange order');
  }

  /// Preview exchange order and required destination form schema
  Future<ExchangePreviewResult> getPreview(String exchangeId) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>('${ApiEndpoints.exchangePreview}/$exchangeId');
    });

    if (response is Map<String, dynamic>) {
      final dynamic rawExchange = response['exchange'] ?? response['data']?['exchange'] ?? response;
      final dynamic rawForm = response['required_data'] ?? response['data']?['required_data'];

      return ExchangePreviewResult(
        exchange: ExchangeModel.fromJson(rawExchange as Map<String, dynamic>),
        requiredData: rawForm != null ? DynamicFormModel.fromJson(rawForm) : null,
      );
    }
    throw Exception('Failed to load exchange preview');
  }

  /// Confirm exchange destination (wallet vs external account)
  Future<ExchangeConfirmResult> confirmExchange({
    required String exchangeId,
    required String destinationType,
    String? walletId,
    Map<String, dynamic>? dynamicFields,
  }) async {
    final Map<String, dynamic> body = {
      'destination_type': destinationType,
      if (walletId != null && walletId.isNotEmpty) 'wallet_id': walletId,
      ...?dynamicFields,
    };

    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        '${ApiEndpoints.exchangeConfirm}/$exchangeId',
        data: body,
      );
    });

    if (response is Map<String, dynamic>) {
      final isAuto = response['is_autometic'] == true || response['data']?['is_autometic'] == true;
      final redirect = response['redirect_url']?.toString() ?? response['data']?['redirect_url']?.toString();
      return ExchangeConfirmResult(isAutomatic: isAuto, redirectUrl: redirect);
    }
    return const ExchangeConfirmResult(isAutomatic: false);
  }

  /// Get manual payment deposit instructions
  Future<ManualExchangeInstructions> getManualInstructions(String exchangeId) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>('${ApiEndpoints.exchangeManualConfirm}/$exchangeId');
    });

    if (response is Map<String, dynamic>) {
      final instructions = response['instructions']?.toString() ?? response['data']?['instructions']?.toString();
      final dynamic rawForm = response['required_data'] ?? response['data']?['required_data'];
      return ManualExchangeInstructions(
        instructions: instructions,
        requiredData: rawForm != null ? DynamicFormModel.fromJson(rawForm) : null,
      );
    }
    return const ManualExchangeInstructions();
  }

  /// Submit payment proof screenshot/reference for manual exchange
  Future<void> submitManualProof({
    required String exchangeId,
    required Map<String, dynamic> fields,
    UploadedFile? proofFile,
  }) async {
    final Map<String, dynamic> dataMap = Map.from(fields);
    if (proofFile != null) {
      dataMap['proof_file'] = MultipartFile.fromBytes([0], filename: proofFile.name);
    }

    final formData = FormData.fromMap(dataMap);

    await handleApiCall(() async {
      return await apiClient.postMultipart<dynamic>(
        '${ApiEndpoints.exchangeManualConfirm}/$exchangeId',
        formData: formData,
      );
    });
  }

  /// Track exchange progress
  Future<ExchangeModel> trackExchange(String exchangeId) async {
    final response = await handleApiCall(() async {
      return await apiClient.post<dynamic>(
        ApiEndpoints.exchangeTrack,
        data: {'exchange_id': exchangeId},
      );
    });

    if (response is Map<String, dynamic>) {
      final dynamic rawExchange = response['exchange'] ?? response['data']?['exchange'] ?? response;
      if (rawExchange is Map<String, dynamic>) {
        return ExchangeModel.fromJson(rawExchange);
      }
    }
    throw Exception('Exchange not found or invalid response');
  }

  /// Get full exchange detail with receipt metadata
  Future<ExchangeModel> getExchangeDetails(String exchangeId) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>('${ApiEndpoints.exchangeDetails}/$exchangeId');
    });

    if (response is Map<String, dynamic>) {
      final dynamic rawExchange = response['exchange'] ?? response['data']?['exchange'] ?? response;
      if (rawExchange is Map<String, dynamic>) {
        return ExchangeModel.fromJson(rawExchange);
      }
    }
    throw Exception('Exchange details not found');
  }

  /// List user exchanges with optional scope ('pending', 'approved', 'refunded', 'cancel')
  Future<PaginatedResponse<ExchangeModel>> getExchangeHistory({
    String? scope,
    int page = 1,
  }) async {
    final endpoint = scope != null && scope.isNotEmpty
        ? '${ApiEndpoints.exchangeList}/$scope'
        : ApiEndpoints.exchangeList;

    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(
        endpoint,
        queryParameters: {'page': page},
      );
    });

    if (response is Map<String, dynamic>) {
      final dynamic rawList = response['exchanges'] ?? response['data']?['exchanges'] ?? response;
      return PaginatedResponse<ExchangeModel>.fromJson(
        rawList as Map<String, dynamic>,
        (item) => ExchangeModel.fromJson(item as Map<String, dynamic>),
      );
    }

    return const PaginatedResponse<ExchangeModel>();
  }
}

final exchangeRepositoryProvider = Provider<ExchangeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExchangeRepository(apiClient);
});
