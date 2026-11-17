class ApiMessage {
  final List<String> success;
  final List<String> error;

  const ApiMessage({
    this.success = const [],
    this.error = const [],
  });

  factory ApiMessage.fromJson(dynamic json) {
    if (json == null) {
      return const ApiMessage();
    }

    final successList = <String>[];
    final errorList = <String>[];

    if (json is Map<String, dynamic>) {
      if (json['success'] != null) {
        if (json['success'] is List) {
          successList.addAll((json['success'] as List).map((e) => e.toString()));
        } else if (json['success'] is String) {
          successList.add(json['success'] as String);
        }
      }

      if (json['error'] != null) {
        if (json['error'] is List) {
          errorList.addAll((json['error'] as List).map((e) => e.toString()));
        } else if (json['error'] is String) {
          errorList.add(json['error'] as String);
        }
      }
    } else if (json is List) {
      errorList.addAll(json.map((e) => e.toString()));
    } else if (json is String) {
      errorList.add(json);
    }

    return ApiMessage(
      success: successList,
      error: errorList,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'error': error,
  };
}

class ApiResponse<T> {
  final String remark;
  final String status;
  final ApiMessage message;
  final T? data;

  const ApiResponse({
    required this.remark,
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  String getErrorMessage() {
    if (message.error.isNotEmpty) {
      return message.error.join('\n');
    }
    if (message.success.isNotEmpty && isError) {
      return message.success.join('\n');
    }
    return 'An unexpected error occurred.';
  }

  String getSuccessMessage() {
    if (message.success.isNotEmpty) {
      return message.success.join('\n');
    }
    return 'Operation successful.';
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(dynamic data)? fromJsonData,
  ]) {
    final remark = json['remark']?.toString() ?? '';
    final status = json['status']?.toString() ?? 'error';
    final message = ApiMessage.fromJson(json['message']);

    T? parsedData;
    if (json.containsKey('data') && json['data'] != null) {
      if (fromJsonData != null) {
        try {
          parsedData = fromJsonData(json['data']);
        } catch (_) {
          parsedData = null;
        }
      } else if (json['data'] is T) {
        parsedData = json['data'] as T;
      }
    }

    return ApiResponse<T>(
      remark: remark,
      status: status,
      message: message,
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson([dynamic Function(T? data)? toJsonData]) => {
    'remark': remark,
    'status': status,
    'message': message.toJson(),
    'data': toJsonData != null ? toJsonData(data) : data,
  };
}
