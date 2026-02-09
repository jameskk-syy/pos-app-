import 'package:dio/dio.dart';
import 'dart:convert';
// import 'package:flutter/foundation.dart';

abstract class BaseRemoteDataSource {
  final Dio dio;

  BaseRemoteDataSource(this.dio);

  String getErrorMessage(DioException e) {
    final response = e.response;
    // final statusCode = response?.statusCode;
    var data = response?.data;

    // debugPrint("--- ERROR RESPONSE START ---");
    // debugPrint("Status Code: $statusCode");
    // debugPrint("Raw Data: $data");
    // debugPrint("--- ERROR RESPONSE END ---");

    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }

    if (data is Map<String, dynamic>) {
      // 0. Resolve _server_messages (can be List or JSON String)
      var serverMessages = data['_server_messages'];
      if (serverMessages is String) {
        try {
          serverMessages = jsonDecode(serverMessages);
        } catch (_) {}
      }

      if (serverMessages is List && serverMessages.isNotEmpty) {
        String? bestMessage;

        for (var msgEntry in serverMessages) {
          try {
            Map<String, dynamic>? msgMap;
            if (msgEntry is String) {
              final decoded = jsonDecode(msgEntry);
              if (decoded is Map<String, dynamic>) msgMap = decoded;
            } else if (msgEntry is Map<String, dynamic>) {
              msgMap = msgEntry;
            }

            if (msgMap != null && msgMap.containsKey('message')) {
              String msg = msgMap['message'].toString();
              // Remove HTML tags
              msg = msg.replaceAll(RegExp(r'<[^>]*>'), '');

              // Heuristic: If it looks like a stock error, prioritize and simplify it
              bool isStockError =
                  msg.toLowerCase().contains('units of') ||
                  msg.toLowerCase().contains('needed in');

              if (isStockError) {
                if (msg.contains('units of')) {
                  msg = msg.split('units of').last;
                }
                if (msg.contains(':')) {
                  msg = msg.split(':').last;
                }
                return msg.trim();
              }

              // Filter out technical Frappe logs
              if (!msg.contains('CharacterLengthExceededError') &&
                  !msg.contains('Error Log') &&
                  !msg.contains('will get truncated')) {
                bestMessage ??= msg;
              }
            }
          } catch (_) {}
        }
        if (bestMessage != null) return bestMessage.trim();
      }

      // 1. Check for specific message object
      final messageObj = data['message'];
      if (messageObj is Map<String, dynamic>) {
        if (messageObj['message'] != null) {
          return _cleanTechnicalError(messageObj['message'].toString());
        }
        if (messageObj['error'] != null) {
          return _cleanTechnicalError(messageObj['error'].toString());
        }
      }

      // 2. Fallback to standard exception/message fields at root
      String fallback =
          (data['exception']?.toString() ??
          data['message']?.toString() ??
          data['error']?.toString() ??
          e.message ??
          'Unknown error occurred');

      return _cleanTechnicalError(fallback);
    }

    // Fallback for non-Map data or other Dio errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Please check your internet.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
    }
  }

  String _cleanTechnicalError(String error) {
    return error
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML
        .replaceAll(
          RegExp(r'frappe\.exceptions\.\w+:'),
          '',
        ) // Strip frappe.exceptions.X:
        .replaceAll(RegExp(r'Error Log \w+:'), '') // Strip "Error Log xyz:"
        .replaceAll("'Title'", '')
        .trim();
  }
}
