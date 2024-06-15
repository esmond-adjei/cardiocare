import 'package:flutter/material.dart';
import 'package:xmonapp/widgets/list_item.dart';

class ListContainer extends StatelessWidget {
  final List<dynamic> listData;
  final String listHeading;

  const ListContainer({
    super.key,
    required this.listHeading,
    required this.listData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey.shade200,
          padding: const EdgeInsets.all(10),
          child: Text(
            listHeading,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listData.length,
          separatorBuilder: (BuildContext context, int index) => Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (BuildContext context, int index) {
            return ListItem(signal: listData[index]);
          },
        ),
      ],
    );
  }
}
