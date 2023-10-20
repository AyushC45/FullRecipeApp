class Recipe {
  final int id;
  final String title;
  final String image;
  final String imageType;
  final List<String> ingredients;
  final String instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.imageType,
    required this.ingredients,
    required this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ingredientsList = json['extendedIngredients'];
    final List<String> ingredients = ingredientsList.map((ingredient) {
      return ingredient['original'] as String;
    }).toList();

    final String instructions = json['instructions'];

    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      imageType: json['imageType'],
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}
