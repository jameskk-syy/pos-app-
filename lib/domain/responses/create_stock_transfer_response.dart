class CreateStockTransferResponse {
  final CreateStockTransfeMessage message;

  CreateStockTransferResponse({
    required this.message,
  });

  factory CreateStockTransferResponse.fromJson(Map<String, dynamic> json) =>
      CreateStockTransferResponse(
        message: CreateStockTransfeMessage.fromJson(json["message"]),
      );
}

class CreateStockTransfeMessage {
  final bool success;
  final String message;
  final Data data;

  CreateStockTransfeMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateStockTransfeMessage.fromJson(Map<String, dynamic> json) => CreateStockTransfeMessage(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: Data.fromJson(json["data"] ?? {}),
      );
}

class Data {
  final String materialRequest;
  final String status;
  final int docstatus;
  final bool submitted;

  Data({
    required this.materialRequest,
    required this.status,
    required this.docstatus,
    required this.submitted,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        materialRequest: json["material_request"] ?? "",
        status: json["status"] ?? "",
        docstatus: json["docstatus"] ?? 0,
        submitted: json["submitted"] ?? false,
      );
}