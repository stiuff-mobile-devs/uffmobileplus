import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:uffmobileplus/app/modules/internal_modules/login/modules/google/controller/auth_google_controller.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GoogleDriveService {
  final folderName = 'UFF+';

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      final authController = Get.find<AuthGoogleController>();
      final account = await authController.authGoogle.getDriveAccount();

      if (account == null) {
        debugPrint('GoogleDriveService: Nenhuma conta encontrada ou login cancelado.');
        return null;
      }

      final authHeaders = await account.authorizationClient.authorizationHeaders(
        [drive.DriveApi.driveFileScope],
        promptIfNecessary: true,
      );

      if (authHeaders == null) {
        debugPrint('GoogleDriveService: Permissão negada pelo usuário.');
        return null;
      }

      final authClient = GoogleAuthClient(authHeaders);
      return drive.DriveApi(authClient);
      
    } catch (e) {
      debugPrint('GoogleDriveService: Erro ao inicializar Drive API - $e');
      return null;
    }
  }

  Future<String?> createFolder() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      final folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final result = await driveApi.files.create(folder);
      
      debugPrint('Pasta criada com sucesso no Drive! ID: ${result.id}');
      return result.id;
      
    } catch (e) {
      debugPrint('GoogleDriveService: Erro ao tentar criar a pasta - $e');
      return null;
    }
  }
}
