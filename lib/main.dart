import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'meal_plan_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData.dark(),
      home: MyBottomNavigationBar(
      ),
    );
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex = 0;
  final List<Widget> _screens = [HomeScreen(), MealPlanScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
                Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.calendar_today),
            label: 'Meal Plan',
          ),
        ],
      ),
    );
  }
}