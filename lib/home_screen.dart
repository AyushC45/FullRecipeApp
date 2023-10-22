import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:full_recipe_app/recipe.dart';
import 'package:full_recipe_app/recipe_detail.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    // Fetch recipes from the API
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    final apiKey = 'ba0cf77242msh348aa0ac45fded0p1de99cjsnbc922a1ac5d6';
    final url = Uri.parse('https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch');

    try {
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': apiKey,
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
              ingredients: [],
              instructions: "",
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecipeDetail(recipeId: recipe.id, imageUrl: recipe.image),
                ),
              );

            },
            child: ListTile(
              title: Text(recipe.title),
              leading: Image.network(recipe.image),
            ),
          );
        },
      ),
    );
  }
}