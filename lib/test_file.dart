import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Browser',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BrowseRecipeScreen(),
    );
  }
}

Future<Recipe> fetchRecipeDetails(int recipeId) async {
  final url = Uri.parse('https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/$recipeId/information');
  final response = await http.get(url, headers: {
    'X-RapidAPI-Key': 'ba0cf77242msh348aa0ac45fded0p1de99cjsnbc922a1ac5d6',
    'X-RapidAPI-Host': 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com',
  });

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return Recipe.fromJson(jsonData);
  } else {
    throw Exception('Failed to load recipe details');
  }
}

class Recipe {
  final String title;
  final String imageUrl;
  final String prepTime;
  final List<String> ingredients;  
  final String instructions;
  final int id;

  Recipe({
    required this.title,
    required this.imageUrl,
    required this.prepTime,
    required this.ingredients,     
    required this.instructions,    
    required this.id,
  });



  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image'],
      prepTime: json['readyInMinutes'].toString(),
      ingredients: (json['ingredients'] as List?)
          ?.map((i) => i['name']?.toString() ?? "")  // Assuming ingredient data is under 'ingredients' in the API response
          .toList() ?? [],
      instructions: json['instructions'] ?? "No instructions provided.", // Parsing instructions
    );
  }
}

class BrowseRecipeScreen extends StatefulWidget {
  @override
  _BrowseRecipeScreenState createState() => _BrowseRecipeScreenState();
}

class _BrowseRecipeScreenState extends State<BrowseRecipeScreen> {
  final apiKey = 'ba0cf77242msh348aa0ac45fded0p1de99cjsnbc922a1ac5d6';
  List<Recipe> recipes = [];
  bool isLoading = false;
  bool filterVegetarian = false;
  bool filterGlutenFree = false;
  bool filterLowCarb = false;

  TextEditingController searchController = TextEditingController();

  Future<void> fetchRecipesByQuery(String query) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch?query=$query');
    final response = await http.get(url, headers: {
      'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<Recipe> loadedRecipes = [];

      for (var item in responseData['results']) {
        loadedRecipes.add(Recipe.fromJson(item));
      }

      setState(() {
        recipes = loadedRecipes;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load recipes');
    }
  }

  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
    });

    final filters = [];
    if (filterVegetarian) {
      filters.add('vegetarian');
    }
    if (filterGlutenFree) {
      filters.add('gluten-free');
    }
    if (filterLowCarb) {
      filters.add('low-carb');
    }

    final filtersQueryParam = filters.join(',');

    final url = Uri.parse('https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/random?number=10&tags=$filtersQueryParam');
    final response = await http.get(url, headers: {
      'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<Recipe> loadedRecipes = [];

      for (var item in responseData['recipes']) {
        loadedRecipes.add(Recipe.fromJson(item));
      }

      setState(() {
        recipes = loadedRecipes;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load recipes');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Browse Recipes')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Recipes',
                      suffixIcon: IconButton(
                        onPressed: () {
                          fetchRecipesByQuery(searchController.text);
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                // Filters
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilterOption(
                      title: 'Vegetarian',
                      isActive: filterVegetarian,
                      onTap: () => setState(() {
                        filterVegetarian = !filterVegetarian;
                        fetchRecipes(); // Fetch recipes when filter changes
                      }),
                    ),
                    FilterOption(
                      title: 'Gluten-free',
                      isActive: filterGlutenFree,
                      onTap: () => setState(() {
                        filterGlutenFree = !filterGlutenFree;
                        fetchRecipes(); // Fetch recipes when filter changes
                      }),
                    ),
                    FilterOption(
                      title: 'Low-carb',
                      isActive: filterLowCarb,
                      onTap: () => setState(() {
                        filterLowCarb = !filterLowCarb;
                        fetchRecipes(); // Fetch recipes when filter changes
                      }),
                    ),
                  ],
                ),
                // Recipes Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(recipe: recipe);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class FilterOption extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  FilterOption({required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(color: isActive ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => RecipeDetailScreen(recipeId: recipe.id),  // Pass the recipe id to the details screen
            ),
          );
        },
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Transform.scale(
            scale: 0.75, // reduce the size by 1/4
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.network(
                      recipe.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                    child: Text(
                      'Prep time: ${recipe.prepTime}',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.grey,

                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  RecipeDetailScreen({required this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  _fetchDetails() async {
    try {
      Recipe recipe = await fetchRecipeDetails(widget.recipeId);
      setState(() {
        _recipe = recipe;
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Splitting the instructions into steps based on periods
    List<String> instructionSteps = _recipe!.instructions.split('.').where((
        step) =>
    step
        .trim()
        .isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_recipe!.title)),
      body: Center( // <-- Center widget wrapping the content
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(_recipe!.imageUrl),
                SizedBox(height: 20),
                Text(_recipe!.title, style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Prep time: ${_recipe!.prepTime}'),
                SizedBox(height: 20),
                Text('Ingredients:', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
                for (var ingredient in _recipe!.ingredients)
                  if (ingredient != null && ingredient
                      .trim()
                      .isNotEmpty)
                    Text('- $ingredient', style: TextStyle(fontSize: 16)),
                // Style for ingredients
                SizedBox(height: 20),
                Text('Instructions:', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
                for (int i = 0; i < instructionSteps.length; i++)
                  Text(
                    '${i + 1}. ${instructionSteps[i].trim()}.',
                    style: TextStyle(fontSize: 16), // Style for instructions
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}