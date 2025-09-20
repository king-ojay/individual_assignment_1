import 'package:flutter/material.dart';
import 'today_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Study Planner', home: TodayScreen());
  }
}
