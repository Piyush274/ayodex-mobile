import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayodex/core/widgets/file_upload_card.dart';
import 'package:ayodex/features/support/data/models/ticket_model.dart';
import 'package:ayodex/features/support/data/repositories/ticket_repository.dart';

class TicketState {
  final bool isLoading;
  final bool isSubmitting;
  final List<TicketModel> tickets;
  final TicketModel? currentTicket;
  final bool hasMore;
  final int page;
  final String? errorMessage;
  final String? successMessage;

  const TicketState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.tickets = const [],
    this.currentTicket,
    this.hasMore = false,
    this.page = 1,
    this.errorMessage,
    this.successMessage,
  });

  TicketState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<TicketModel>? tickets,
    TicketModel? currentTicket,
    bool clearCurrentTicket = false,
    bool? hasMore,
    int? page,
    String? errorMessage,
    String? successMessage,
  }) {
    return TicketState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      tickets: tickets ?? this.tickets,
      currentTicket: clearCurrentTicket ? null : (currentTicket ?? this.currentTicket),
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class TicketController extends StateNotifier<TicketState> {
  final TicketRepository _repository;

  TicketController(this._repository) : super(const TicketState());

  Future<void> loadTickets({bool refresh = false}) async {
    final page = refresh ? 1 : state.page;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final paginated = await _repository.getTickets(page: page);
      final updatedList = refresh ? paginated.data : [...state.tickets, ...paginated.data];

      state = state.copyWith(
        isLoading: false,
        tickets: updatedList,
        hasMore: paginated.hasMorePages,
        page: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadTicketView(String ticketNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final ticket = await _repository.viewTicket(ticketNumber);
      state = state.copyWith(isLoading: false, currentTicket: ticket);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<TicketModel?> createTicket({
    required String subject,
    required int priority,
    required String message,
    List<UploadedFile>? attachments,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final ticket = await _repository.createTicket(
        subject: subject,
        priority: priority,
        message: message,
        attachments: attachments,
      );
      state = state.copyWith(
        isSubmitting: false,
        tickets: [ticket, ...state.tickets],
        currentTicket: ticket,
        successMessage: 'Ticket #${ticket.ticket} created successfully!',
      );
      return ticket;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> replyTicket({
    required int ticketId,
    required String message,
    List<UploadedFile>? attachments,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final newMessage = await _repository.replyTicket(
        ticketId: ticketId,
        message: message,
        attachments: attachments,
      );

      if (state.currentTicket != null) {
        final updatedMessages = [...state.currentTicket!.messages, newMessage];
        final updatedTicket = TicketModel(
          id: state.currentTicket!.id,
          ticket: state.currentTicket!.ticket,
          subject: state.currentTicket!.subject,
          status: 2, // Customer Reply
          priority: state.currentTicket!.priority,
          lastReply: DateTime.now(),
          createdAt: state.currentTicket!.createdAt,
          messages: updatedMessages,
        );
        state = state.copyWith(
          isSubmitting: false,
          currentTicket: updatedTicket,
          successMessage: 'Reply sent successfully',
        );
      } else {
        state = state.copyWith(isSubmitting: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> closeTicket(int ticketId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _repository.closeTicket(ticketId);
      if (state.currentTicket != null && state.currentTicket!.id == ticketId) {
        final updatedTicket = TicketModel(
          id: state.currentTicket!.id,
          ticket: state.currentTicket!.ticket,
          subject: state.currentTicket!.subject,
          status: 3, // Closed
          priority: state.currentTicket!.priority,
          lastReply: state.currentTicket!.lastReply,
          createdAt: state.currentTicket!.createdAt,
          messages: state.currentTicket!.messages,
        );
        state = state.copyWith(
          isSubmitting: false,
          currentTicket: updatedTicket,
          successMessage: 'Ticket closed successfully',
        );
      } else {
        state = state.copyWith(isSubmitting: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final ticketControllerProvider = StateNotifierProvider<TicketController, TicketState>((ref) {
  final repo = ref.watch(ticketRepositoryProvider);
  return TicketController(repo);
});
