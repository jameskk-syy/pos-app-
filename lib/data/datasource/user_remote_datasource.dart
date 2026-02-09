import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/models/message.dart';

class RemoteDataSource {
  final Dio dio;
  final StorageService storageService;
  RemoteDataSource(this.dio, this.storageService);

  Future<void> saveMessageToPrefs(Map<String, dynamic> data) async {
    String messageJson = jsonEncode(data['message']);
    await storageService.setString('saved_message', messageJson);
  }

  Future<Message?> getMessageFromPrefs() async {
    String? messageJson = await storageService.getString('saved_message');

    if (messageJson != null) {
      Map<String, dynamic> messageMap = jsonDecode(messageJson);
      return Message.fromJson(messageMap);
    }
    return null;
  }

  Future<void> deleteMessageFromPrefs() async {
    await storageService.remove('saved_message');
  }
}
