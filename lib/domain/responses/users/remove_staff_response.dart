class RemoveStaffResponse {
  final Message message;

  RemoveStaffResponse({required this.message});

  factory RemoveStaffResponse.fromJson(Map<String, dynamic> json) {
    return RemoveStaffResponse(message: Message.fromJson(json['message']));
  }
}

class Message {
  final bool success;
  final String message;

  Message({required this.success, required this.message});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(success: json['success'], message: json['message']);
  }
}
