
import 'dart:html';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:full_recipe_app/recipe.dart';
import 'package:full_recipe_app/recipe_detail.dart';

List<Recipe> recipes = [];

class MyCalendar extends StatefulWidget{
  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar>{
  late final ValueNotifier<List<Recipe>> _selectedRecipe;
  Map<DateTime, List<Recipe>> recipesByDate = {};
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff;
  List<Recipe> recipes = [];
  DateTime _firstDay = DateTime.now().subtract(Duration(days: 365));
  DateTime _lastDay = DateTime.now().add(Duration(days: 365));
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;


  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    fetchRecipes();
  }
  @override
  void removeRecipe(Recipe recipe,DateTime day) {
    setState(() {
      recipesByDate[day]?.remove(recipe);
    });
  }

  void addRecipeToDay(DateTime day, Recipe recipe) {
    setState(() {
    if (!recipesByDate.containsKey(day)) {
      recipesByDate[day] = [recipe];
    } else {
      recipesByDate[day]?.add(recipe);
    }
  });
    }
  Future<void> fetchRecipes() async {
    final apiKey = 'ba0cf77242msh348aa0ac45fded0p1de99cjsnbc922a1ac5d6'; // Replace with your actual API key
    final url = Uri.parse('https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch');

    try {
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': apiKey, // Use 'X-RapidAPI-Key' for RapidAPI
        'X-RapidAPI-Host': 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        setState(() {
          recipes = results.map((recipeData) {
            return Recipe(
              id: recipeData['id'],
              title: recipeData['title'],
              image: recipeData['image'],
              imageType: recipeData['imageType'],
              ingredients: [], // Populate this with the ingredients
              instructions: "", // Populate this with the instructions
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch recipes');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
      ),
      body: Column(
        children: [
          TableCalendar<Recipe>(
            startingDayOfWeek: StartingDayOfWeek.monday,
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              focusedDay = focusedDay;
            },
          ),
          Expanded(
          child: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            child: Column(
                children: [
              ListTile(
              title: Text(recipe.title),
                leading: Image.network(recipe.image),
          ),
            TextButton(
              onPressed: () {
              addRecipeToDay(_selectedDay, recipe);
            },
              child: const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                  'Add recipe',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
              ),
            ),
             TextButton(
                 onPressed: () {
                   removeRecipe(recipe, _selectedDay);
                 },
                 child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                 'Remove',
                    style: TextStyle(
                      fontSize: 10,
                    )
               ),
             )
             )
            ],
            )
          );
        },
          ),
          ),
        ],
      ),
    );
  }
  }

