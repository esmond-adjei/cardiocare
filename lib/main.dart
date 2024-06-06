import 'package:flutter/material.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/theme.dart';
import 'package:xmonapp/screens/history_screen.dart';
import 'package:xmonapp/screens/home_screen.dart';
import 'package:xmonapp/screens/record_screen.dart';
import 'package:xmonapp/screens/settings_screen.dart';
import 'package:xmonapp/screens/pages/connect_device.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'X-Monitoring App',
        theme: customRedTheme,
        home: const MainScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/record': (context) => const RecordScreen(),
          '/history': (context) => const HistoryScreen(),
          '/setting': (context) => const SettingsScreen(),
          '/device': (context) => const ConnectDevice(),
        });
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

// initialize db here
  @override
  void initState() {
    // initialize screens here
    _screens = [
      const HomeScreen(),
      const RecordScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];
    init();

    super.initState();
  }

  init() async => await DatabaseHelper().onInitCreate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14.0,
        unselectedFontSize: 12.0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
