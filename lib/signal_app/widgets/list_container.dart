import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cardiocare/signal_app/model/signal_model.dart';
import 'package:cardiocare/signal_app/widgets/list_item.dart';
import 'package:cardiocare/utils/format_datetime.dart';

class ListContainer extends StatefulWidget {
  final List<Signal> listData;
  final String listHeading;
  final bool expandable;

  const ListContainer({
    super.key,
    this.expandable = false,
    required this.listHeading,
    required this.listData,
  });

  @override
  State<ListContainer> createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  String _selectedPeriod = 'All';
  String _selectedCategory = 'All';
  String _groupBy = 'Date';

  List<Signal> get filteredData {
    return widget.listData.where((signal) {
      final now = DateTime.now();
      final signalTime = signal.startTime;
      final timeDiff = now.difference(signalTime);

      bool periodFilter = switch (_selectedPeriod) {
        'All' => true,
        'Today' => timeDiff.inDays == 0,
        'This Week' => timeDiff.inDays < 7,
        'This Month' => timeDiff.inDays < 30,
        _ => false,
      };

      bool categoryFilter = _selectedCategory == 'All' ||
          signal.signalType.toString().split('.').last == _selectedCategory;

      return periodFilter && categoryFilter;
    }).toList();
  }

  void _removeSignal(Signal signal) {
    setState(() {
      widget.listData.remove(signal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        if (filteredData.isEmpty)
          const Center(child: Text('No data yet'))
        else
          ...groupedListItems,
        const SizedBox(height: 20),
      ],
    );
  }

  List<Widget> get groupedListItems {
    if (_groupBy == 'Date') {
      final groupedMap = <String, List<Signal>>{};
      for (var signal in filteredData) {
        final dateKey = signal.startTime.toString().split(' ')[0];
        groupedMap.putIfAbsent(dateKey, () => []).add(signal);
      }

      return groupedMap.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                formatRelativeDayDate(entry.key),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entry.value.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 0, thickness: 0.4),
              itemBuilder: (_, index) => ListItem(
                signal: entry.value[index],
                onDismissed: _removeSignal,
              ),
            ),
          ],
        );
      }).toList();
    } else {
      return filteredData
          .map((signal) => ListItem(signal: signal, onDismissed: _removeSignal))
          .toList();
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.listHeading,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildHeaderAction(context),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context) {
    if (widget.listData.isNotEmpty && widget.expandable) {
      return IconButton(
        onPressed: () => Navigator.pushNamed(context, '/history'),
        icon: const FaIcon(FontAwesomeIcons.arrowRight,
            size: 20, color: Colors.grey),
      );
    } else if (!widget.expandable) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onSelected: _handleMenuSelection,
        itemBuilder: (BuildContext context) => [
          ..._buildPopupMenuSection(
              'Filter by Period', ['All', 'Today', 'This Week', 'This Month']),
          const PopupMenuDivider(),
          ..._buildPopupMenuSection('Group By', ['Date', 'Category']),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  List<PopupMenuEntry<String>> _buildPopupMenuSection(
      String title, List<String> items) {
    return [
      PopupMenuItem<String>(
        enabled: false,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      ...items
          .map((item) => PopupMenuItem<String>(value: item, child: Text(item))),
    ];
  }

  void _handleMenuSelection(String value) {
    setState(() {
      if (['All', 'Today', 'This Week', 'This Month'].contains(value)) {
        _selectedPeriod = value;
      } else if (['All', 'ECG', 'BP', 'BTemp'].contains(value)) {
        _selectedCategory = value;
      } else if (['Date', 'Category'].contains(value)) {
        _groupBy = value;
      }
    });
  }
}
