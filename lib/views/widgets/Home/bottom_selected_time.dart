import 'package:flutter/material.dart';

class BottomPopup extends StatelessWidget {
  final List<String> listToSelected;
  final ValueChanged<String> onSelected;

  const BottomPopup({super.key, required this.listToSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: ListView.builder(
        itemCount: listToSelected.length,
        itemBuilder: (context, index) {
          final time = listToSelected[index];
          return ListTile(
            title: Text(time),
            onTap: () => onSelected(time),
          );
        },
      ),
    );
  }
}
