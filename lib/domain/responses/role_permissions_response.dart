import 'package:flutter/foundation.dart';

class RolePermissionsResponse {
  final List<DocTypePermission> message;

  RolePermissionsResponse({required this.message});

  factory RolePermissionsResponse.fromJson(Map<String, dynamic> json) {
    final messageData = json['message'];
    debugPrint(
      "RolePermissionsResponse.fromJson - message type: ${messageData.runtimeType}",
    );
    debugPrint("RolePermissionsResponse.fromJson - message data: $messageData");

    List<DocTypePermission> permissions = [];

    if (messageData is List) {
      permissions = messageData
          .map((e) => DocTypePermission.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (messageData is Map<String, dynamic>) {
      // Structure A: {"message": {"permissions": [...]}}
      if (messageData.containsKey('permissions') &&
          messageData['permissions'] is List) {
        permissions = (messageData['permissions'] as List)
            .map((e) => DocTypePermission.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // Structure B: {"message": {"DocType1": {"read": 1, ...}, "DocType2": {...}}}
      else {
        messageData.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            final Map<String, dynamic> permMap = Map.from(value);
            if (!permMap.containsKey('parent')) {
              permMap['parent'] = key;
            }
            permissions.add(DocTypePermission.fromJson(permMap));
          }
        });
      }
    } else {
      debugPrint(
        "RolePermissionsResponse - Unexpected message type: ${messageData.runtimeType}",
      );
    }

    return RolePermissionsResponse(message: permissions);
  }
}

class DocTypePermission {
  final String docType;
  final List<String> enabledPermissions;

  DocTypePermission({required this.docType, required this.enabledPermissions});

  factory DocTypePermission.fromJson(Map<String, dynamic> json) {
    final List<String> perms = [];
    final possiblePerms = [
      'read',
      'write',
      'create',
      'delete',
      'submit',
      'cancel',
      'amend',
      'print',
      'email',
      'export',
      'import',
      'report',
      'share',
      'select',
    ];

    for (var perm in possiblePerms) {
      if (json[perm] == 1) {
        perms.add(_capitalize(perm));
      }
    }

    return DocTypePermission(
      docType: json['parent'] ?? json['name'] ?? '',
      enabledPermissions: perms,
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
