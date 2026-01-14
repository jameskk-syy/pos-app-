// lib/domain/responses/create_grn_response.dart

class CreateGrnResponse {
  final String status;
  final String code;
  final String message;
  final GrnData data;
  final String lpoNo;
  final String grnNo;

  CreateGrnResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    required this.lpoNo,
    required this.grnNo,
  });

  factory CreateGrnResponse.fromJson(Map<String, dynamic> json) {
    final messageData = json['message'] as Map<String, dynamic>;
    
    return CreateGrnResponse(
      status: messageData['status'] as String,
      code: messageData['code'] as String,
      message: messageData['message'] as String,
      data: GrnData.fromJson(messageData['data'] as Map<String, dynamic>),
      lpoNo: messageData['lpo_no'] as String,
      grnNo: messageData['grn_no'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'status': status,
        'code': code,
        'message': message,
        'data': data.toJson(),
        'lpo_no': lpoNo,
        'grn_no': grnNo,
      }
    };
  }
}

class GrnData {
  final int docstatus;
  final int receivedItems;

  GrnData({
    required this.docstatus,
    required this.receivedItems,
  });

  factory GrnData.fromJson(Map<String, dynamic> json) {
    return GrnData(
      docstatus: json['docstatus'] as int,
      receivedItems: json['received_items'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docstatus': docstatus,
      'received_items': receivedItems,
    };
  }
}