import 'widgets/event_card.dart';
import 'widgets/calendar_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lịch làm việc")),
      body: Column(
        children: [
          CalendarWidget(),  // Hiển thị lịch tháng
          Expanded(
            child: ListView(
              children: [
                EventCard(title: "Cuộc họp nhóm", time: "10:00 AM - 11:00 AM",onEdit:() => (){
                  print("hello");
                },),
                EventCard(title: "Làm báo cáo", time: "2:00 PM - 3:30 PM",onEdit:() => (){
                  print("hello");
                },),
                EventCard(title: "Làm báo cáo", time: "8:00 PM - 9:30 PM",onEdit:() => (){
                  print("hello");
                },),
                
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_event');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
