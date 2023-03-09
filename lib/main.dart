import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/SplashScreen.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  showFlutterNotification(message);
}

void showFlutterNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // // TODO add a proper drawable resource to android, for now using
          // //      one that already exists in example app.
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FirebaseStorage.instance;

  final storageRef = FirebaseStorage.instance.ref();

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
    }
  }

  fcmForegroundMessageHandler(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
    showFlutterNotification(message);
  }

  String token = "";

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.
      print("FCM TOKEN REFRESHED: $fcmToken");
      setState(() {
        token = fcmToken;
      });
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
      print(err);
    });
    requestNotificationPermission();
    FirebaseMessaging.onMessage.listen(fcmForegroundMessageHandler);
    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
              // _resolved = true;
              // initialMessage = value?.data.toString();
              print("getInitialMessage(): ${value?.data.toString()}");
            },
          ),
        );
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print("Data: ${message.data}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMS Teacher App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      //home: Scaffold(
      // appBar: AppBar(
      //   title: const Text("LMS App"),
      // ),
      // body: Center(
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Text("FCM Token: $token"),
      //       ElevatedButton(
      //         onPressed: () async {
      //           FilePickerResult? result = await FilePicker.platform.pickFiles();

      //           if (result != null) {
      //             File file = File(result.files.single.path!);
      //             String fileName = result.files.first.name;
      //             print(fileName);
      //             await storage
      //                 .ref("temp/uploads/$fileName")
      //                 .putFile(file)
      //                 .then((p0) async => print(await p0.ref.getDownloadURL()))
      //                 .onError((error, stackTrace) => print(error));
      //           } else {
      //             // User canceled the picker
      //             print("User canceled the picker");
      //           }
      //         },
      //         child: const Text("Upload File"),
      //       ),
      //     ],
      //   ),
      // ),
      // ),
    );
  }
}
