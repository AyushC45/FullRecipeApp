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
  var isLoading = false;
  String error = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch recipes from the API
    fetchRecipes();
  }

  Future<void> fetchRecipes({String query = ''}) async {
    final apiKey = '81eb466186msh250d40552a8d0c6p1c592cjsn373627577f73';
    final url = Uri.parse(
        'https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch?query=$query');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host':
            'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com',
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
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch recipes';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Recipes',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              onSubmitted: (value) {
                // Fetch recipes based on the search query when the user submits the search
                fetchRecipes(query: searchQuery);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecipeDetail(
                            recipeId: recipe.id, imageUrl: recipe.image),
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
          ),
        ],
      ),
    );
  }
}
