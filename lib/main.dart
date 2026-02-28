import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';
import 'models/medicine.dart';
import 'services/medicine_service.dart';
import 'services/notification_service.dart';
import 'screens/today_screen.dart';
import 'screens/medicines_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Init Hive safely
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MedicineAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MedicineLogAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(LogStatusAdapter());
  await Hive.close();
  await MedicineService.init();

  // Init notifications with timeout — never block app startup
  try {
    await NotificationService().init().timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
  } catch (_) {}

  runApp(const MedBuddyApp());
}

class MedBuddyApp extends StatelessWidget {
  const MedBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedBuddy',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _tabs = const [
    TodayScreen(),
    MedicinesScreen(),
    HistoryScreen(),
  ];

  final _titles = ['Today', 'My Medicines', 'History'];

  @override
  void initState() {
    super.initState();
    // Init notification listeners after app loads — not during startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AwesomeNotifications().setListeners(
          onActionReceivedMethod: NotificationController.onActionReceived,
        );
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Text(_titles[_currentIndex]),
              centerTitle: false,
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppTheme.surface,
          elevation: 0,
          indicatorColor: AppTheme.primary.withOpacity(0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today, color: AppTheme.primary),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.medication_outlined),
              selectedIcon: Icon(Icons.medication, color: AppTheme.primary),
              label: 'Medicines',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primary),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> onActionReceived(ReceivedAction action) async {}
}
