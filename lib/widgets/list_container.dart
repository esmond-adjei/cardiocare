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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
            Divider(
              height: 1,
              color: Colors.grey.shade300,
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return ListItem(signal: listData[index]);
              },
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 1,
                color: Colors.grey.shade300,
              ),
              itemCount: listData.length,
            ),
          ],
        ),
      ),
    );
  }
}
