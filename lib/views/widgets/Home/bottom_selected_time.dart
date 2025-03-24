import 'package:flutter/material.dart';

class BottomPopup extends StatefulWidget {
  final List<String> listToSelected;

  BottomPopup({super.key, required this.listToSelected});

  @override
  _BottomPopupState createState() => _BottomPopupState();
}

class _BottomPopupState extends State<BottomPopup> {
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Hủy Bỏ"),
                ),
                Text(
                  "Lựa chọn thời gian",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    print("Bạn đã xác nhận: $selectedTime");
                    Navigator.pop(context, selectedTime);
                  },
                  child: Text("Xác Nhận"),
                ),
              ],
            ),
            Divider(),
            Expanded( // Để danh sách có thể scroll
              child: ListView.builder(
                itemCount: widget.listToSelected.length,
                itemBuilder: (context, index) {
                  String item = widget.listToSelected[index];
                  bool isSelected = item == selectedTime;

                  return ListTile(
                    title: Text(item),
                    trailing:
                        isSelected ? Icon(Icons.check, color: Colors.blue) : null,
                    onTap: () {
                      setState(() {
                        selectedTime = item;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
