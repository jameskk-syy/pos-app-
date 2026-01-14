import 'package:pos/domain/models/message.dart';
import 'package:pos/domain/requests/register_user.dart';

abstract class RegisterRepository {
  Future<Message> registerUser(RegisterRequest registerRequest);
}
