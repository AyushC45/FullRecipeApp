import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    final apiKey = 'ba0cf77242msh348aa0ac45fded0p1de99cjsnbc922a1ac5d6'; // Replace with your actual API key
    final url = Uri.parse('https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/${widget.recipeId}/information');

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
            instructions = data['instructions'].replaceAll(RegExp(r'<[^>]*>'), '');
          } else {
            instructions = data['instructions'] ?? "Instructions coming soon. Try whatever you want";
          }
        });
      } else {
        throw Exception('Failed to fetch recipe details');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (widget.imageUrl.isNotEmpty) Image.network(widget.imageUrl), // Display the recipe image if URL is not empty
            SizedBox(height: 16.0),
            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(ingredients.join('\n')),
            SizedBox(height: 16.0),
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(instructions),
          ],
        ),
      ),
    );
  }
}
