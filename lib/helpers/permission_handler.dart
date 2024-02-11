import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermissions() async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    return true;
  } else {
    return false;
  }
}
