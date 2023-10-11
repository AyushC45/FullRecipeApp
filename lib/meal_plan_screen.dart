import 'package:flutter/material.dart';

class MealPlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plan Screen'),
      ),
      body: Center(
        child: Text("Here's your Meal Plan."),
      ),
    );
  }
}