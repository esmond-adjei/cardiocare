import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xmonapp/user/login_screen.dart';
import 'package:xmonapp/user/register_screen.dart';
import 'package:xmonapp/screens/drawers/monitoring_screen.dart';
import 'package:xmonapp/services/models/db_helper.dart';
import 'package:xmonapp/services/theme.dart';
import 'package:xmonapp/screens/history_screen.dart';
import 'package:xmonapp/screens/home_screen.dart';
import 'package:xmonapp/screens/health_blog_screen.dart';
import 'package:xmonapp/screens/settings_screen.dart';
import 'package:xmonapp/screens/drawers/connect_device.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DatabaseHelper(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'X-Monitoring App',
      theme: customRedTheme,
      darkTheme: customRedDarkTheme, //ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/blog': (context) => const HealthBlogScreen(),
        '/history': (context) => const HistoryScreen(),
        '/setting': (context) => const SettingsScreen(),
        '/device': (context) => const ConnectDevice(),
        '/record': (context) => const SingleMonitorLayout(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
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
  late int _selectedIndex;
  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const HealthBlogScreen(),
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
    // init();
    super.initState();
  }

  // init() async => await DatabaseHelper().onInitCreate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house, size: 20),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.list, size: 20),
            label: 'history',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.newspaper, size: 20),
            label: 'health',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gear, size: 20),
            label: 'settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
