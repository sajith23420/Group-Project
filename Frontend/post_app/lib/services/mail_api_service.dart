import 'package:post_app/models/mail_model.dart';
import 'package:post_app/services/api_client.dart';

class MailApiService {
  final ApiClient _apiClient;

  MailApiService(this._apiClient);

  Future<CreateMailResponse> createMail(CreateMailRequest request) async {
    return _apiClient.post<CreateMailResponse>(
      '/mails',
      data: request.toJson(),
      fromJson: (json) => CreateMailResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<MailModel>> getUserMails() async {
    return _apiClient.getList<MailModel>(
      '/mails/my-mails',
      fromJsonT: (json) => MailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> adminUpdateMailStatus(String mailId, AdminUpdateMailStatusRequest request) async {
    await _apiClient.put<void>(
      '/mails/admin/$mailId/status',
      data: request.toJson(),
    );
  }

  Future<List<MailModel>> adminGetAllMails() async {
    return _apiClient.getList<MailModel>(
      '/mails/admin/all',
      fromJsonT: (json) => MailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> sendTrackingEmail(SendTrackingEmailRequest request) async {
    await _apiClient.post<void>(
      '/mails/send-tracking-email',
      data: request.toJson(),
    );
  }
}