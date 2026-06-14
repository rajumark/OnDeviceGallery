import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestFilePermission() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<bool> hasFilePermission() async {
    return await Permission.manageExternalStorage.isGranted;
  }
}
