import 'package:flutter/material.dart';
import 'package:xmonapp/services/theme.dart';
import 'package:xmonapp/screens/history_screen.dart';
import 'package:xmonapp/screens/home_screen.dart';
import 'package:xmonapp/screens/record_screen.dart';
import 'package:xmonapp/screens/settings_screen.dart';
import 'package:xmonapp/widgets/nav_drawer.dart';

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
        // ThemeData(
        //   useMaterial3: true,
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        // ),
        home: const MainScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/record': (context) => const RecordScreen(),
          '/history': (context) => const HistoryScreen(),
          '/setting': (context) => const SettingsScreen(),
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

  static const List<Map<String, Widget>> _screens = [
    {'Home': HomeScreen()},
    {'Record': RecordScreen()},
    {'History': HistoryScreen()},
    {'Settings': SettingsScreen()},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _screens[_selectedIndex].keys.first,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: const AppDrawer(),
      body: _screens[_selectedIndex].values.first,
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
