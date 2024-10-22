import 'dart:async'; // Tambahkan import ini
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    // Membuat saluran notifikasi
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // Ganti dengan ID saluran Anda
      'your_channel_name', // Ganti dengan nama saluran Anda
      description:
          'your_channel_description', // Ganti dengan deskripsi saluran Anda
      importance: Importance.max,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Meminta izin untuk menampilkan notifikasi
    await _requestNotificationPermission();
  }

  static Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      // Izin diberikan
    }
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Ganti dengan ID saluran Anda
      'your_channel_name', // Ganti dengan nama saluran Anda
      channelDescription:
          'your_channel_description', // Ganti dengan deskripsi saluran Anda
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Menggunakan ID unik untuk setiap notifikasi
    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000); // ID unik

    await _notificationsPlugin.show(
        notificationId, title, body, platformChannelSpecifics);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan untuk membatalkan timer saat widget dihapus
    super.dispose();
  }

  void startTimer() {
    // Membuat timer untuk mengirim notifikasi setiap 30 detik
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      NotificationService.showNotification('Backup Otomatis Berhasil',
          'Berhasil menyimpan data ke Google Drive');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Notifikasi Lokal')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              startTimer(); // Memulai timer saat tombol diklik
            },
            child: Text('Mulai Notifikasi Setiap 30 Detik'),
          ),
        ),
      ),
    );
  }
}
