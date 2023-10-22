import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstorage/localstorage.dart';

class RecipeDetail extends StatefulWidget {
  final int recipeId;
  final String imageUrl;

  RecipeDetail({required this.recipeId, required this.imageUrl});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  String recipeName = "";
  List<dynamic> ingredients = [];
  String instructions = "";
  final localStorage = LocalStorage('recipe_data.json');

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    final apiKey = 'ba0cf77242msh348aa0ac45fded0p1de99cjsnbc922a1ac5d6';
    final url = Uri.parse(
        'https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/${widget.recipeId}/information');

    try {
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipeName = data['title'];
          if (data['extendedIngredients'] is List) {
            ingredients = data['extendedIngredients']
                .map((ingredient) => ingredient['name'].toString())
                .toList();
          }
          // Check if the instructions are in HTML format
          if (data['instructions'] is String) {
            // Remove HTML tags from instructions
            instructions =
                data['instructions'].replaceAll(RegExp(r'<[^>]*>'), '');
          } else {
            instructions = data['instructions'] ??
                "Instructions coming soon. Try whatever you want";
          }
        });
      } else {
        throw Exception('Failed to fetch recipe details');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to save the recipe data to local storage
  void saveRecipeToLocalStorage() {
    final recipeData = {
      'recipeId': widget.recipeId,
      'recipeName': recipeName,
      'imageUrl': widget.imageUrl,
    };

    List<dynamic> starRecipes = localStorage.getItem("starRecipes") ?? [];
    starRecipes.add(recipeData); // Add the new recipe data to the list

    localStorage.setItem('starRecipes', starRecipes);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: saveRecipeToLocalStorage,
                icon: Icon(Icons.calendar_today),
                label: Text('Add to Meal Plan'),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16.0), // Add left margin
                    child: Text(
                      'Ingredients:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ingredients.map((ingredient) {
                  return Text(
                    '• $ingredient',
                    style: TextStyle(fontSize: 16),
                  );
                }).toList(),
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16.0), // Add left margin
                    child: Text(
                      'Instructions:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructions,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 25.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
