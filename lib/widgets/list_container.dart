import 'package:cardiocare/services/models/signal_model.dart';
import 'package:cardiocare/utils/format_datetime.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cardiocare/widgets/list_item.dart';

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
      bool periodFilter = _selectedPeriod == 'All' ||
          (_selectedPeriod == 'Today' &&
              signal.startTime
                  .isAfter(DateTime.now().subtract(const Duration(days: 1)))) ||
          (_selectedPeriod == 'This Week' &&
              signal.startTime
                  .isAfter(DateTime.now().subtract(const Duration(days: 7)))) ||
          (_selectedPeriod == 'This Month' &&
              signal.startTime
                  .isAfter(DateTime.now().subtract(const Duration(days: 30))));

      bool categoryFilter = _selectedCategory == 'All' ||
          signal.signalType.toString().split('.').last == _selectedCategory;

      return periodFilter && categoryFilter;
    }).toList();
  }

  List<Widget> get groupedListItems {
    if (_groupBy == 'Date') {
      Map<String, List<Signal>> groupedMap = {};
      for (var signal in filteredData) {
        String dateKey = signal.startTime.toString().split(' ')[0];
        if (!groupedMap.containsKey(dateKey)) {
          groupedMap[dateKey] = [];
        }
        groupedMap[dateKey]!.add(signal);
      }

      return groupedMap.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GROUPED CATEGORY: DATE || CATEGORY
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Text(
                formatRelativeDayDate(entry.key),
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            // LIST OF EACH ITEM
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entry.value.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    ListItem(signal: entry.value[index]),
                    if (index != entry.value.length - 1)
                      const Divider(height: 0, thickness: 0.4),
                  ],
                );
              },
            ),
          ],
        );
      }).toList();
    } else {
      return filteredData.map((signal) => ListItem(signal: signal)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.listHeading,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (widget.listData.isNotEmpty && widget.expandable)
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/history'),
                      icon: const FaIcon(
                        FontAwesomeIcons.arrowRight,
                        size: 20,
                        color: Colors.grey,
                      ),
                    )
                  else
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (String value) {
                        setState(() {
                          if (['All', 'Today', 'This Week', 'This Month']
                              .contains(value)) {
                            _selectedPeriod = value;
                          } else if (['All', 'ECG', 'BP', 'BTemp']
                              .contains(value)) {
                            _selectedCategory = value;
                          } else if (['Date', 'Category'].contains(value)) {
                            _groupBy = value;
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'Period',
                          enabled: false,
                          child: Text('Filter by Period'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'All',
                          child: Text('All'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Today',
                          child: Text('Today'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'This Week',
                          child: Text('This Week'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'This Month',
                          child: Text('This Month'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'Category',
                          enabled: false,
                          child: Text('Filter by Category'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'All',
                          child: Text('All'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'ECG',
                          child: Text('ECG'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'BP',
                          child: Text('Blood Pressure'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'BTemp',
                          child: Text('Body Temperature'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'Group',
                          enabled: false,
                          child: Text('Group By'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Date',
                          child: Text('Date'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Category',
                          child: Text('Category'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        if (filteredData.isEmpty) const Center(child: Text('No data yet')),
        ...groupedListItems,
        const SizedBox(height: 20),
      ],
    );
  }
}
