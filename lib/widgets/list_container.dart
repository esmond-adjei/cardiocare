import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xmonapp/widgets/list_item.dart';

class ListContainer extends StatelessWidget {
  final List<dynamic> listData;
  final String listHeading;
  final VoidCallback? routeToHistoryScreen;

  const ListContainer({
    super.key,
    required this.listHeading,
    required this.listData,
    this.routeToHistoryScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                listHeading,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (listData.isNotEmpty && routeToHistoryScreen != null)
                GestureDetector(
                  onTap: routeToHistoryScreen,
                  child: const FaIcon(
                    FontAwesomeIcons.arrowRight,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        if (listData.isEmpty) const Center(child: Text('No data yet')),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listData.length,
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.1),
          ),
          itemBuilder: (BuildContext context, int index) {
            return ListItem(signal: listData[index]);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
