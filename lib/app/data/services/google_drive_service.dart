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

  Future<drive.DriveApi?> _getDriveApi({bool interactive = true}) async {
    try {
      final authController = Get.find<AuthGoogleController>();
      final account = await authController.authGoogle.getDriveAccount(interactive: interactive);

      if (account == null) {
        debugPrint('GoogleDriveService: Nenhuma conta encontrada ou login cancelado.');
        return null;
      }

      final authHeaders = await account.authorizationClient.authorizationHeaders(
        [drive.DriveApi.driveFileScope],
        promptIfNecessary: interactive,
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

  Future<String?> checkFolderExists({bool interactive = true}) async {
    try {
      final driveApi = await _getDriveApi(interactive: interactive);
      if (driveApi == null) return null;

      final result = await driveApi.files.list(
        q: "mimeType = 'application/vnd.google-apps.folder' "
            "and name = '$folderName' and trashed = false",
        spaces: 'drive',
        $fields: 'files(id, name)',
        pageSize: 1,
      );

      final files = result.files;
      if (files == null || files.isEmpty) {
        debugPrint('GoogleDriveService: Pasta "$folderName" não encontrada.');
        return null;
      }

      debugPrint('GoogleDriveService: Pasta encontrada. ID: ${files.first.id}');
      return files.first.id;
    } catch (e) {
      debugPrint('GoogleDriveService: Erro ao verificar se a pasta existe - $e');
      return null;
    }
  }

  Future<String?> ensureFolderExists({bool interactive = true}) async {
    final existingId = await checkFolderExists(interactive: interactive);
    if (existingId != null) return existingId;
    return createFolder(interactive: interactive);
  }

  Future<String?> createFolder({bool interactive = true}) async {
    try {
      final driveApi = await _getDriveApi(interactive: interactive);
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
