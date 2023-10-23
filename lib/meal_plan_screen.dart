import 'package:localstorage/localstorage.dart';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:full_recipe_app/recipe.dart';
import 'recipe_detail.dart';

List<Recipe> recipes = [];

class MyCalendar extends StatefulWidget {
  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  late final ValueNotifier<List<Recipe>> _selectedRecipe;
  Map<DateTime, List<Recipe>> recipesByDate = {};
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  List<Recipe> recipes = [];
  List<Recipe> starredRecipes = [];
  DateTime _firstDay = DateTime.now().subtract(Duration(days: 365));
  DateTime _lastDay = DateTime.now().add(Duration(days: 365));
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final LocalStorage localStorage = LocalStorage('recipe_data.json');

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    loadStarredRecipes();
  }

  void removeRecipe(Recipe recipe, DateTime day) {
    setState(() {
      recipesByDate[day]?.remove(recipe);
    });
  }

  void addRecipeToDay(DateTime day, Recipe recipe) {
    if (!recipesByDate.containsKey(day)) {
      setState(() {
        recipesByDate[day] = [recipe];
      });
    } else {
      setState(() {
        recipesByDate[day]?.add(recipe);
      });
    }
  }

  void loadStarredRecipes() async {
    final starredRecipesData = localStorage.getItem('starRecipes');
    print(starredRecipesData);
    if (starredRecipesData != null) {
      setState(() {
        starredRecipes = (starredRecipesData as List<dynamic>).map((data) {
          return Recipe(
            id: data['recipeId'],
            title: data['recipeName'],
            image: data['imageUrl'],
            ingredients: [],
            instructions: "",
            imageType: '',
          );
        }).toList();
      });
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

  void _removeRecipeFromSelectedDate(Recipe recipe, DateTime day) {
    if (recipesByDate.containsKey(day)) {
      setState(() {
        recipesByDate[day]?.remove(recipe);
      });
    }
  }

  Future<void> toggleStarRecipe(Recipe recipe) async {
    if (starredRecipes.contains(recipe)) {
      setState(() {
        starredRecipes.remove(recipe);
      });

      // Remove from local storage
      final updatedStarredRecipes = starredRecipes
          .map((recipe) => {
                'recipeId': recipe.id,
                'recipeName': recipe.title,
                'imageUrl': recipe.image,
              })
          .toList();
      await localStorage.setItem('starRecipes', updatedStarredRecipes);
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
            child: Column(
              children: [
                Text(
                  'Meal Plan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: recipesByDate[_selectedDay]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final recipe = recipesByDate[_selectedDay]![index];
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(recipe.title),
                              leading: Image.network(recipe.image),
                            ),
                            TextButton(
                              onPressed: () {
                                _removeRecipeFromSelectedDate(
                                    recipe, _selectedDay);
                              },
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  "Remove",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  'All Starred Recipes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: starredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = starredRecipes[index];
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(recipe.title),
                              leading: Image.network(recipe.image),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    toggleStarRecipe(recipe);
                                  },
                                  child: const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      'Unstar',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    addRecipeToDay(_selectedDay, recipe);
                                  },
                                  child: const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      'Add to date',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
