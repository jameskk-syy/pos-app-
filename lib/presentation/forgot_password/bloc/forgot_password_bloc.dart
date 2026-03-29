import 'package:bloc/bloc.dart';
import 'package:pos/domain/repository/authenticating_user_repo.dart';
import 'package:pos/domain/requests/users/send_otp_request.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthenticateUserRepo authenticateUserRepo;

  ForgotPasswordBloc({required this.authenticateUserRepo})
    : super(ForgotPasswordInitial()) {
    on<RequestOtp>(_onRequestOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<ResetPassword>(_onResetPassword);
  }

  Future<void> _onRequestOtp(
    RequestOtp event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(SendOtpLoading());
    try {
      final response = await authenticateUserRepo.sendOtpEmail(
        SendOtpRequest(email: event.email),
      );
      if (response.success) {
        emit(SendOtpSuccess(message: response.message));
      } else {
        emit(SendOtpFailure(error: response.error ?? response.message));
      }
    } catch (e) {
      emit(SendOtpFailure(error: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtp event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(VerifyOtpLoading());
    try {
      final response = await authenticateUserRepo.verifyEmailCode(
        event.email,
        event.code,
      );

      // response format: {"message": {"success": true, "message": "Email verified successfully", "verified": true}}
      bool success = false;
      String message = "Verification failed";

      if (response['message'] != null && response['message'] is Map) {
        final msg = response['message'] as Map<String, dynamic>;
        success = msg['success'] == true || msg['verified'] == true;
        message = msg['message'] ?? message;
      }

      if (success) {
        emit(VerifyOtpSuccess(message: message));
      } else {
        emit(VerifyOtpFailure(error: message));
      }
    } catch (e) {
      emit(VerifyOtpFailure(error: e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPassword event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ResetPasswordLoading());
    try {
      final response = await authenticateUserRepo.resetPassword(
        email: event.email,
        newPassword: event.newPassword,
      );

      // response format: {"message": {"success": true, "message": "Password reset successfully..."}}
      bool success = false;
      String message = "Reset failed";

      if (response['message'] != null && response['message'] is Map) {
        final msg = response['message'] as Map;
        success = msg['success'] == true;
        message = msg['message'] ?? message;
      }

      if (success) {
        emit(ResetPasswordSuccess(message: message));
      } else {
        emit(ResetPasswordFailure(error: message));
      }
    } catch (e) {
      emit(ResetPasswordFailure(error: e.toString()));
    }
  }
}
