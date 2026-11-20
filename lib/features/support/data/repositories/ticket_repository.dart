import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/constants/api_endpoints.dart';
import 'package:ayodex/core/models/paginated_response.dart';
import 'package:ayodex/core/network/api_client.dart';
import 'package:ayodex/core/network/network_providers.dart';
import 'package:ayodex/core/repositories/base_repository.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';
import '../models/ticket_model.dart';

class TicketRepository extends BaseRepository {
  TicketRepository(ApiClient apiClient) : super(apiClient);

  Future<PaginatedResponse<TicketModel>> getTickets({int page = 1}) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>(
        ApiEndpoints.ticket,
        queryParameters: {'page': page},
      );
    });

    if (response is Map<String, dynamic>) {
      final dynamic raw = response['tickets'] ?? response['data']?['tickets'] ?? response['data'] ?? response;
      if (raw is Map<String, dynamic>) {
        return PaginatedResponse<TicketModel>.fromJson(
          raw,
          (json) => TicketModel.fromJson(json),
        );
      }
    }
    return const PaginatedResponse<TicketModel>();
  }

  Future<TicketModel> createTicket({
    required String subject,
    required int priority,
    required String message,
    List<UploadedFile>? attachments,
  }) async {
    final Map<String, dynamic> formMap = {
      'subject': subject,
      'priority': priority,
      'message': message,
    };

    if (attachments != null && attachments.isNotEmpty) {
      final List<MultipartFile> files = [];
      for (final file in attachments) {
        if (file.path.isNotEmpty) {
          files.add(await MultipartFile.fromFile(file.path, filename: file.name));
        } else {
          files.add(MultipartFile.fromBytes([], filename: file.name));
        }
      }
      formMap['attachments[]'] = files;
    }

    final formData = FormData.fromMap(formMap);

    final response = await handleApiCall(() async {
      return await apiClient.postMultipart<dynamic>(
        ApiEndpoints.ticketCreate,
        formData: formData,
      );
    });

    if (response is Map<String, dynamic>) {
      final ticketData = response['ticket'] ?? response['data']?['ticket'] ?? response['data'] ?? response;
      return TicketModel.fromJson(ticketData as Map<String, dynamic>);
    }
    throw Exception('Invalid create ticket response format');
  }

  Future<TicketModel> viewTicket(String ticketNumber) async {
    final response = await handleApiCall(() async {
      return await apiClient.get<dynamic>('${ApiEndpoints.ticketView}/$ticketNumber');
    });

    if (response is Map<String, dynamic>) {
      final dynamic ticketData = response['ticket'] ?? response['data']?['ticket'] ?? response['data'] ?? response;
      final dynamic rawMessages = response['messages'] ?? response['data']?['messages'];

      final ticket = TicketModel.fromJson(ticketData as Map<String, dynamic>);
      if (rawMessages is List) {
        final messages = rawMessages
            .whereType<Map<String, dynamic>>()
            .map((m) => TicketMessageModel.fromJson(m))
            .toList();
        return TicketModel(
          id: ticket.id,
          ticket: ticket.ticket,
          subject: ticket.subject,
          status: ticket.status,
          priority: ticket.priority,
          lastReply: ticket.lastReply,
          createdAt: ticket.createdAt,
          messages: messages,
        );
      }
      return ticket;
    }
    throw Exception('Invalid ticket view response format');
  }

  Future<TicketMessageModel> replyTicket({
    required int ticketId,
    required String message,
    List<UploadedFile>? attachments,
  }) async {
    final Map<String, dynamic> formMap = {
      'message': message,
    };

    if (attachments != null && attachments.isNotEmpty) {
      final List<MultipartFile> files = [];
      for (final file in attachments) {
        if (file.path.isNotEmpty) {
          files.add(await MultipartFile.fromFile(file.path, filename: file.name));
        } else {
          files.add(MultipartFile.fromBytes([], filename: file.name));
        }
      }
      formMap['attachments[]'] = files;
    }

    final formData = FormData.fromMap(formMap);

    final response = await handleApiCall(() async {
      return await apiClient.postMultipart<dynamic>(
        '${ApiEndpoints.ticketReply}/$ticketId',
        formData: formData,
      );
    });

    if (response is Map<String, dynamic>) {
      final messageData = response['message'] ?? response['data']?['message'] ?? response['data'] ?? response;
      return TicketMessageModel.fromJson(messageData as Map<String, dynamic>);
    }
    throw Exception('Invalid reply ticket response format');
  }

  Future<void> closeTicket(int ticketId) async {
    await handleApiCall(() async {
      return await apiClient.post<dynamic>('${ApiEndpoints.ticketClose}/$ticketId');
    });
  }
}

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TicketRepository(client);
});
