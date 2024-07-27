import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cardiocare/signal_app/model/signal_enums.dart';
import 'package:cardiocare/signal_app/widgets/history_tab_view.dart';
import 'package:cardiocare/signal_app/screens/monitoring_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _currentColor = SignalType.ecg.color;
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(
        () => _currentColor = SignalType.values[_tabController.index].color);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 600,
            decoration: BoxDecoration(
              color: _currentColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: AppBar(
              scrolledUnderElevation: 10,
              title: const Text('History'),
              backgroundColor: Colors.transparent,
              actions: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                ),
              ],
              bottom: TabBar(
                dividerHeight: 0,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'ECG'),
                  Tab(text: 'Blood Pressure'),
                  Tab(text: 'Body Temperature'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: SignalType.values
              .map((type) => HistoryTabView(dataType: type))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _currentColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SingleMonitorLayout(initialScreen: _tabController.index),
              ),
            );
          },
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
    );
  }
}
