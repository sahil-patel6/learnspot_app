import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notification_permissions/notification_permissions.dart';
// import 'package:permission_handler/permission_handler.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

requestNotificationPermission() async {
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("Notification permission denied");
    // PermissionStatus permissionStatus= await Permission.notification.request();
    // print(permissionStatus);
    PermissionStatus notifcation_permissionStatus =
        await NotificationPermissions.requestNotificationPermissions(
      openSettings: true,
    );
    print(notifcation_permissionStatus);
  }
}
