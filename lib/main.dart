import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/login.dart';

Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Initialize the Firebase app
  await Firebase.initializeApp();
  MyHomePageState().showDialogAlert(message.data["title"], message.data["body"]);
  print('onBackgroundMessage received: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    print(swAvailable && swInterceptAvailable);
    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController = AndroidServiceWorkerController.instance();

      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request.url);
          return null;
        },
      );
    }
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Digital घंटी',
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
            duration: 3000,
            splash: Text("Digital \n घंटी", textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.white)),
            nextScreen: MyHomePage(title: 'Digital घंटी'),
            // splashTransition: SplashTransition.fadeTransition,
            // pageTransitionType: PageTransitionType.scale,
            backgroundColor: Colors.blue));
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late InAppWebViewController _webViewController;
  double progress = 0;
  String? token;
  WebStorageManager webStorageManager = WebStorageManager.instance();

  @override
  void initState() {
    super.initState();
    // Used to get the current FCM token
    _messaging.getToken().then((token) {
      setState(() {
        this.token = token;
      });
    }).catchError((e) {
      print(e);
    });
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        showDialogAlert(message.data["title"], message.data["body"]);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      showDialogAlert(message.data["title"], message.data["body"]);
    });

    FirebaseMessaging.onMessage.listen((event) {
      showDialogAlert(event.data["title"], event.data["body"]);
    });
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
    // });
  }

  showDialogAlert(String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Wrap(
            spacing: 10,
            children: <Widget>[
              Icon(Icons.report, color: Colors.red),
              Text(
                "Alert!",
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                child: Text(
                  "$title",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.redAccent, fontSize: 18),
                ),
              ),
              Text("$body"),
            ],
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          actions: <Widget>[
            FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0.0, 0.0),
        child: Container(),
      ),
      body: Container(
        child: Column(
          children: [
            progress < 1.0
                ? LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[800]!),
                  )
                : Center(), // this perform the loading on every page load
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.tryParse('https://hbms.rxhealth.in/')), // your website url
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    useShouldOverrideUrlLoading: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    useShouldInterceptAjaxRequest: true,
                    useShouldInterceptFetchRequest: true,
                  ),
                ),
                onProgressChanged: (_, load) {
                  setState(() {
                    progress = load / 100;
                  });
                },
                onWebViewCreated: (controller) {
                  this._webViewController = controller;
                },
                onAjaxReadyStateChange: (InAppWebViewController controller, AjaxRequest request) async {
                  if (request.url.toString() == 'https://hbmsapi.rxhealth.in/api/admin_login') {
                    if (request.status!.toInt() == 200) {
                      var res = jsonDecode(request.responseText.toString());
                      String authToken = res["result"]["token"];
                      if (authToken.isNotEmpty) {
                        final data = {"token": token.toString(), "plateform": Platform.operatingSystem};
                        final String url = 'https://hbmsapi.rxhealth.in/api/update_device_token';
                        final client = new http.Client();
                        final response = await client.post(
                          Uri.tryParse(url) as Uri,
                          headers: {
                            HttpHeaders.contentTypeHeader: 'application/json',
                            HttpHeaders.authorizationHeader: "Bearer $authToken",
                          },
                          body: json.encode(data),
                        );
                      }
                    }
                  }
                },
                onLoadStop: (InAppWebViewController controller, url) async {},
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
