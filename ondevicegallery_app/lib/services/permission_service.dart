import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestFilePermission() async {
    if (await Permission.photos.isGranted) return true;
    if (await Permission.mediaLibrary.isGranted) return true;
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> hasFilePermission() async {
    final photosStatus = await Permission.photos.isGranted;
    final mediaLibraryStatus = await Permission.mediaLibrary.isGranted;
    return photosStatus || mediaLibraryStatus;
  }
}
