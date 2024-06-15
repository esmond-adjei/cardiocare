import 'package:flutter/material.dart';
import 'package:xmonapp/screens/login_screen.dart';
import 'package:xmonapp/screens/register_screen.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/theme.dart';
import 'package:xmonapp/screens/history_screen.dart';
import 'package:xmonapp/screens/home_screen.dart';
import 'package:xmonapp/screens/record_screen.dart';
import 'package:xmonapp/screens/settings_screen.dart';
import 'package:xmonapp/screens/drawers/connect_device.dart';

void main() {
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
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const MainScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/record': (context) => const RecordScreen(),
          '/history': (context) => const HistoryScreen(),
          '/setting': (context) => const SettingsScreen(),
          '/device': (context) => const ConnectDevice(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
        });
  }
}

class MainScreen extends StatefulWidget {
  final int selectedIndex;

  const MainScreen({
    super.key,
    this.selectedIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    // const RecordScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _selectedIndex = widget.selectedIndex;
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.analytics),
          //   label: 'Record',
          // ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
